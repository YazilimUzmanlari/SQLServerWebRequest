CREATE PROCEDURE [dbo].[sp_GetN11ProductById]
	@apiKey				nvarchar(max),
	@apiSecretKey		nvarchar(max),
	@productId		nvarchar(max) 
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
      <sch:GetProductByProductIdRequest>
         <auth>
			<appKey>' + @apiKey + '</appKey>
			<appSecret>' + @apiSecretKey + '</appSecret>
         </auth>
         <productId>' + @productId + '</productId>
      </sch:GetProductByProductIdRequest>
   </soapenv:Body>
</soapenv:Envelope>
'
	declare @ResponseText nvarchar(max)

	exec sp_GetHttpRequest 'https://api.n11.com/ws/categoryService', 'POST', 'text/xml', null, null, null,@RequestBody, @ResponseXML out 



	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as n3 )
	Select		
				Coalesce(b.Data.value('(stockItem/id/text())[1]',			'float')		,'')				Id,
				Coalesce(b.Data.value('(stockItem/currencyAmount/text())[1]',			'float')		,'')	CurrencyAmount,
				Coalesce(b.Data.value('(stockItem/displayPrice/text())[1]',			'float')		,'')		DisplayPrice,
				Coalesce(b.Data.value('(stockItem/optionPrice/text())[1]',			'float')		,'')		OptiopPrice,
				Coalesce(b.Data.value('(stockItem/quantity/text())[1]',			'int')		,'')				Quantity,
				Coalesce(b.Data.value('(stockItem/version/text())[1]',			'float')		,'')			Version

	From @ResponseXML.nodes('/env:Envelope/env:Body/n3:GetProductByProductIdResponse/product/stockItems') as b(DATA)


end