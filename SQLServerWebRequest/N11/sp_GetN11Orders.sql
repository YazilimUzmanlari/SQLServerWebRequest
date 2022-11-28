CREATE PROCEDURE [dbo].[sp_GetN11Orders]
	@apiKey			nvarchar(max),
	@apiSecretKey	nvarchar(max),
	@currentPage	nvarchar(max),
	@pageCount		nvarchar(max)
as
begin
	Declare @responseData		nvarchar(max)
	declare @urlAddress			nvarchar(max)
	declare @requestBody		nvarchar(max)
	declare @responseXML		xml

	set @requestBody = N'
		<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://www.n11.com/ws/schemas">
		   <soapenv:Header/>
		   <soapenv:Body>
			  <sch:DetailedOrderListRequest>
				 <auth>
					<appKey>' + @apiKey + '</appKey>
					<appSecret>' + @apiSecretKey + '</appSecret>
				 </auth>
				  <searchData>
					<productId></productId>
					<status></status>
					<buyerName></buyerName>
					<orderNumber></orderNumber>
					<productSellerCode></productSellerCode>
					<recipient></recipient>
					<sameDayDelivery></sameDayDelivery>
					<period>
					   <startDate></startDate>
					   <endDate></endDate>
					</period>
					<sortForUpdateDate>true</sortForUpdateDate>
				 </searchData>
				 <pagingData>
					<currentPage>' + @currentPage + '</currentPage>
					<pageSize>' + @pageCount + '</pageSize>
					<totalCount></totalCount>
					<pageCount></pageCount>
				 </pagingData>
			  </sch:DetailedOrderListRequest>
		   </soapenv:Body>
		</soapenv:Envelope>
	'
	set @urlAddress = 'https://api.n11.com/ws/categoryService'
	exec sp_GetHttpRequest @urlAddress, 'POST', 'text/xml', null, null, null, @requestBody, @responseData out

	set @responseXML = Cast(@responseData as xml)
	select @responseXML
	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env], 'http://www.n11.com/ws/schemas' as n3)
	Select	Orders.Data.value('(../../id/text())[1]',			'nvarchar(max)') OrderId,
			Orders.Data.value('(../../orderNumber/text())[1]',	'nvarchar(max)') OrderNumber,
			Orders.Data.value('(../../status/text())[1]',		'nvarchar(max)') [Status],
			Orders.Data.value('(../../totalAmount/text())[1]',	'nvarchar(max)') TotalAmount,
			Orders.Data.value('(approvedDate/text())[1]',		'nvarchar(max)') ApprovedDate,
			Orders.Data.value('(commission/text())[1]',			'nvarchar(max)') Commission,
			Orders.Data.value('(dueAmount/text())[1]',			'nvarchar(max)') DueAmount,
			Orders.Data.value('(price/text())[1]',				'nvarchar(max)') Price,
			Orders.Data.value('(productId/text())[1]',			'nvarchar(max)') ProductId,
			Orders.Data.value('(productSellerCode/text())[1]',	'nvarchar(max)') ProductCode,
			Orders.Data.value('(productName/text())[1]',		'nvarchar(max)') ProductName,
			Orders.Data.value('(quantity/text())[1]',			'nvarchar(max)') Quantity
	From	@responseXML.nodes('/env:Envelope/env:Body/n3:DetailedOrderListResponse/orderList/order/orderItemList/orderItem') as Orders(Data)

end