CREATE PROCEDURE [dbo].[sp_GetN11ProductImagesById]
	@apiKey			nvarchar(max),
	@apiSecretKey	nvarchar(max),
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
	--Select @RequestBody = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><GetTopLevelCategoriesRequest xmlns="http://www.n11.com/ws/schemas"><auth xmlns=""><appKey>' + @apiKey + '</appKey><appSecret>' + @apiSecret + '</appSecret></auth></GetTopLevelCategoriesRequest></s:Body></s:Envelope>'
	
	declare @ResponseText nvarchar(max)

	exec sp_GetHttpRequest 'https://api.n11.com/ws/categoryService', 'POST', 'text/xml', null, null, null, @RequestBody, @ResponseXML out 



	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as n3 )
	Select		Coalesce(b.Data.value('(image/order/text())[1]',			'int')		,'')				ImageOrder,
				Coalesce(b.Data.value('(image/url/text())[1]',			'nvarchar(max)')		,'')		ImageUrl
	From @ResponseXML.nodes('/env:Envelope/env:Body/n3:GetProductByProductIdResponse/product/images') as b(DATA)


end