CREATE PROCEDURE [dbo].[sp_GetN11Products]
	@apiKey			nvarchar(max),
	@apiSecretKey	nvarchar(max),
	@currentPage	nvarchar(max),
	@pageSize		nvarchar(max)
as
begin
	Declare @responseData	nvarchar(max)
	declare @urlAddress		nvarchar(max)
	declare @requestBody	nvarchar(max)
	declare @responseXML	xml

	set @requestBody = N'
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://www.n11.com/ws/schemas">
		<soapenv:Header/>
		<soapenv:Body>
			<sch:GetProductListRequest>
				<auth>
					<appKey>' + @apiKey + '</appKey>
					<appSecret>' + @apiSecretKey + '</appSecret>
				</auth>
				<pagingData>
					<currentPage>' + @currentPage + '</currentPage>
					<pageSize>' + @pageSize + '</pageSize>
				</pagingData>
			</sch:GetProductListRequest>
		</soapenv:Body>
	</soapenv:Envelope>
	'
	set @urlAddress = 'https://api.n11.com/ws/categoryService'
	exec sp_GetHttpRequest @urlAddress, 'POST', 'text/xml', null, null, null, @requestBody, @responseData out

	set @responseXML = Cast(@responseData as xml)
	select @responseXML
	;With XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env], 'http://www.n11.com/ws/schemas' as n3)
	Select	Products.Data.value('(id/text())[1]',						'nvarchar(max)') ProductId,
			Products.Data.value('(productSellerCode/text())[1]',		'nvarchar(max)') SellerCode,
			Products.Data.value('(title/text())[1]',					'nvarchar(max)') Title,
			Products.Data.value('(subtitle/text())[1]',					'nvarchar(max)') SubTitle,
			Products.Data.value('(currencyAmount/text())[1]',			'nvarchar(max)') CurrencyAmount,
			Products.Data.value('(currencyType/text())[1]',				'nvarchar(max)') CurrencyType,
			case 
				when Coalesce(Products.Data.value('(currencyType/text())[1]',		'int'), 0) = 1 then 'TL'
				when Coalesce(Products.Data.value('(currencyType/text())[1]',		'int'), 0) = 2 then 'USD'
				when Coalesce(Products.Data.value('(currencyType/text())[1]',		'int'), 0) = 3 then 'EUR'
			end CurrencyTypeName, 
			Products.Data.value('(isDomestic/text())[1]',				'nvarchar(max)') IsDomestic,
			Products.Data.value('(price/text())[1]',					'nvarchar(max)') Price,
			Products.Data.value('(approvalStatus/text())[1]',			'nvarchar(max)') ApprovalStatus,
			Products.Data.value('(stockItems/stockItem/currencyAmount/text())[1]',		'nvarchar(max)') StockItemCurrencyAmount,
			Products.Data.value('(stockItems/stockItem/displayPrice/text())[1]',		'nvarchar(max)') StockItemDisplayPrice,
			Products.Data.value('(stockItems/stockItem/optionPrice/text())[1]',			'nvarchar(max)') StockItemOptionPrice,
			Products.Data.value('(stockItems/stockItem/id/text())[1]',					'nvarchar(max)') StockItemId,
			Products.Data.value('(stockItems/stockItem/quantity/text())[1]',			'nvarchar(max)') StockItemQuantity,
			Products.Data.value('(../../pagingData/totalCount/text())[1]',				'nvarchar(max)') totalCount
	From	@responseXML.nodes('/env:Envelope/env:Body/n3:GetProductListResponse/products/product') as Products(Data)


end