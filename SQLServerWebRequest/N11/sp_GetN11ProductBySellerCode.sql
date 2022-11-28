CREATE PROCEDURE [dbo].[sp_GetN11ProductBySellerCode]
	@apiKey			nvarchar(max),
	@apiSecretKey	nvarchar(max),
	@productCode		nvarchar(max) 
as
begin


	set nocount on;
	SET TEXTSIZE 2147483647;


	Declare @ResponseXML xml
	Declare @RequestBody nvarchar(max)	
	
	SET @ResponseXML = ''
	SET @RequestBody = ''
	select @RequestBody = '
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://www.n11.com/ws/schemas">
   <soapenv:Header/>
   <soapenv:Body>
      <sch:GetProductBySellerCodeRequest>
         <auth>
			<appKey>' + @apiKey + '</appKey>
			<appSecret>' + @apiSecretKey + '</appSecret>
         </auth>
         <sellerCode>' + @productCode + '</sellerCode>
      </sch:GetProductBySellerCodeRequest>
   </soapenv:Body>
</soapenv:Envelope>
'
	--Select @RequestBody = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><GetTopLevelCategoriesRequest xmlns="http://www.n11.com/ws/schemas"><auth xmlns=""><appKey>' + @apiKey + '</appKey><appSecret>' + @apiSecret + '</appSecret></auth></GetTopLevelCategoriesRequest></s:Body></s:Envelope>'
	
	declare @ResponseText nvarchar(max)

	exec sp_GetHttpRequest 'https://api.n11.com/ws/categoryService', 'POST','text/xml', null, null, null, @RequestBody, @ResponseXML out 

	--select @ResponseXML

	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as n3 )
	Select		Coalesce(b.Data.value('(id/text())[1]',			'float')		,'')										Id,
				--Coalesce(b.Data.value('(stockItems/stockItem/id/text())[1]',			'nvarchar(max)')		,'')		StockId,
				Coalesce(b.Data.value('(productSellerCode/text())[1]',			'nvarchar(max)')		,'')				ProductSellerCode,
				Coalesce(b.Data.value('(title/text())[1]',			'nvarchar(max)')		,'')							Title,
				Coalesce(b.Data.value('(subtitle/text())[1]',			'nvarchar(max)')		,'')						Subtitle,
				Coalesce(b.Data.value('(currencyAmount/text())[1]',			'float')		,'')							CurrencyAmount,
				Coalesce(b.Data.value('(currencyType/text())[1]',			'int')		,'')								CurrencyType,
				Coalesce(b.Data.value('(isDomestic/text())[1]',			'bit')		,'')									IsDomestic,
				Coalesce(b.Data.value('(price/text())[1]',			'float')		,'')									Price,
				Coalesce(b.Data.value('(displayPrice/text())[1]',			'float')		,'')							DisplayPrice,
				Coalesce(b.Data.value('(stockItems/stockItem/quantity/text())[1]',			'int')		,'')				Quantity,
				Coalesce(b.Data.value('(approvalStatus/text())[1]',			'int')		,'')								ApprovalStatus,
				Coalesce(b.Data.value('(saleStatus/text())[1]',			'int')		,'')									SaleStatus,
				Coalesce(b.Data.value('(preparingDay/text())[1]',			'int')		,'')								PreparingDay,
				Coalesce(b.Data.value('(productCondition/text())[1]',			'int')		,'')							ProductCondition,
				Coalesce(b.Data.value('(description/text())[1]',			'nvarchar(max)')		,'')					Description,
				Coalesce(b.Data.value('(salesStartDate/text())[1]',			'datetime')		,'')							SalesStartDate,
				Coalesce(b.Data.value('(salesEndDate/text())[1]',			'datetime')		,'')							SalesEndDate,
				Coalesce(b.Data.value('(shipmentTemplate/text())[1]',			'nvarchar(max)')		,'')				ShipmentTemplate,
				Coalesce(b.Data.value('(category/id/text())[1]',			'float')		,'')							CategoryId,
				Coalesce(b.Data.value('(category/fullName/text())[1]',			'nvarchar(max)')		,'')				CategoryFullName,
				Coalesce(b.Data.value('(category/name/text())[1]',			'nvarchar(max)')		,'')					CategoryName
	From @ResponseXML.nodes('/env:Envelope/env:Body/n3:GetProductBySellerCodeResponse/product') as b(DATA)


end