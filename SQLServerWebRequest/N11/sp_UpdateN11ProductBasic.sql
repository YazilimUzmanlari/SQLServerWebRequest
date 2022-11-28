CREATE PROCEDURE [dbo].[sp_UpdateN11ProductBasic]
	@apiKey				nvarchar(max),
	@apiSecretKey		nvarchar(max),
	@ItemCode			nvarchar(max),
	@StockId			nvarchar(max),
	@Price				nvarchar(max),
	@CurrencyType		nvarchar(max),
	@Quantity			nvarchar(max)
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
			<sch:UpdateProductBasicRequest>
				<auth>
					<appKey>' + @apiKey + '</appKey>
					<appSecret>' + @apiSecretKey + '</appSecret>
				</auth>
				<productId/>
				<productSellerCode>' + @ItemCode + '</productSellerCode>
				<price>' + @Price + '</price>
				<currencyType>' + @CurrencyType + '</currencyType>
				<stockItems>
					<stockItem>
						<id>' +  @StockId + '</id>
						<optionPrice></optionPrice>
						<quantity>' + @Quantity + '</quantity>
					</stockItem>
				</stockItems>
			</sch:UpdateProductBasicRequest>
		</soapenv:Body>
	</soapenv:Envelope>
'

	--select @RequestBody
	
	exec sp_GetHttpRequest 'https://api.n11.com/ws/productService', 'POST', 'text/xml', null, null, null,@RequestBody, @ResponseXML out 

	--select @ResponseXML


	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as ns3 )
	select	Coalesce(b.Data.value('(../result/status/text())[1]',					'nvarchar(max)')		,'')	Result,
			Coalesce(b.Data.value('(productSellerCode/text())[1]',					'nvarchar(max)')		,'')	ItemCode,
			Coalesce(b.Data.value('(title/text())[1]',								'nvarchar(max)')		,'')	ItemName,
			Coalesce(b.Data.value('(currencyAmount/text())[1]',						'float')				,0)	EurPrice,
			Coalesce(b.Data.value('(stockItems/stockItem/displayPrice/text())[1]',	'float')				,0)	TRYPrice,
			Coalesce(b.Data.value('(stockItems/stockItem/quantity/text())[1]',		'float')				,0)	Quantity
	From @ResponseXML.nodes('/env:Envelope/env:Body/ns3:UpdateProductBasicResponse/product') as b(DATA)

	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as ns3 )
	select	Coalesce(b.Data.value('(../result/status/text())[1]',					'nvarchar(max)')		,'')	Result
	From @ResponseXML.nodes('/env:Envelope/env:Body/ns3:UpdateProductBasicResponse/product') as b(DATA)

end