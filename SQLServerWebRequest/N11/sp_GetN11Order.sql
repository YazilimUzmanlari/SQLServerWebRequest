CREATE PROCEDURE [dbo].[sp_GetN11Order]
	@apiKey			nvarchar(max),
	@apiSecretKey	nvarchar(max),
	@orderId	nvarchar(max)
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
      <sch:OrderDetailRequest>
         <auth>
			<appKey>' + @apiKey + '</appKey>
			<appSecret>' + @apiSecretKey + '</appSecret>
         </auth>
         <orderRequest>
            <id>' + @orderId + '</id>
         </orderRequest>
      </sch:OrderDetailRequest>
   </soapenv:Body>
</soapenv:Envelope>
'
	--Select @RequestBody = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><GetTopLevelCategoriesRequest xmlns="http://www.n11.com/ws/schemas"><auth xmlns=""><appKey>' + @apiKey + '</appKey><appSecret>' + @apiSecret + '</appSecret></auth></GetTopLevelCategoriesRequest></s:Body></s:Envelope>'
	
	declare @ResponseText nvarchar(max)

	exec sp_GetHttpRequest 'https://api.n11.com/ws/OrderService', 'POST','text/xml', null, null, null, @RequestBody, @ResponseXML out 


	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as n3 )
	Select		Coalesce(b.Data.value('(id/text())[1]',			'float')		,'')											Id,
				Coalesce(b.Data.value('(productSellerCode/text())[1]',			'nvarchar(max)')		,'')				ProductSellerCode,
				Coalesce(b.Data.value('(title/text())[1]',			'nvarchar(max)')		,'')							Title,
				Coalesce(b.Data.value('(subtitle/text())[1]',			'nvarchar(max)')		,'')						Subtitle,
				Coalesce(b.Data.value('(currencyAmount/text())[1]',			'float')		,'')							CurrencyAmount,
				Coalesce(b.Data.value('(currencyType/text())[1]',			'int')		,'')								CurrencyType,
				case 
					when Coalesce(b.Data.value('(currencyType/text())[1]','int'),'') = 1 then 'TL'
					when Coalesce(b.Data.value('(currencyType/text())[1]','int'),'') = 2 then 'USDT'
					when Coalesce(b.Data.value('(currencyType/text())[1]','int'),'') = 3 then 'EUR'
				end CurrencyTypeName,
				Coalesce(b.Data.value('(isDomestic/text())[1]',			'bit')		,'')									IsDomestic,
				Coalesce(b.Data.value('(price/text())[1]',			'float')		,'')									Price,
				Coalesce(b.Data.value('(approvalStatus/text())[1]',			'int')		,'')								ApprovalStatus,
				Coalesce(b.Data.value('(salesStatus/text())[1]',			'int')		,'')								SalesStatus,
				Coalesce(b.Data.value('(stockItems/stockItem/currencyAmount/text())[1]',			'float')		,'')	StockItemCurrencyAmount,
				Coalesce(b.Data.value('(stockItems/stockItem/displayPrice/text())[1]',			'float')		,'')		StockItemDisplayPrice,
				Coalesce(b.Data.value('(stockItems/stockItem/optionPrice/text())[1]',			'float')		,'')		StockItemOptionPrice,
				Coalesce(b.Data.value('(stockItems/stockItem/id/text())[1]',			'float')		,'')				StockItemId,
				Coalesce(b.Data.value('(stockItems/stockItem/quantity/text())[1]',			'int')		,'')				StockItemQuantity,
				Coalesce(b.Data.value('(stockItems/stockItem/version/text())[1]',			'float')		,'')			StockItemVersion, 
				Coalesce(b.Data.value('(../../pagingData/totalCount/text())[1]',			'int')		,'')	totalCount 

	From @ResponseXML.nodes('/env:Envelope/env:Body/n3:GetProductListResponse/products/product') as b(DATA)


end