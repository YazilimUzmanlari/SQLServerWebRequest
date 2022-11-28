CREATE PROCEDURE [dbo].[sp_UpdateN11ProductQuantity]
	@apiKey				nvarchar(max),
	@apiSecretKey		nvarchar(max),
	@ItemCode			nvarchar(max),
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
	<sch:UpdateStockByStockSellerCodeRequest>
         <auth>
			<appKey>' + @apiKey + '</appKey>
			<appSecret>' + @apiSecretKey + '</appSecret>
         </auth>
         <stockItems>
            <stockItem>
               <sellerStockCode>' + @ItemCode + '</sellerStockCode>
               <quantity>' + @Quantity + '</quantity>
			   <version>1</version>
            </stockItem>
         </stockItems>
      </sch:UpdateStockByStockSellerCodeRequest>
   </soapenv:Body>
</soapenv:Envelope>
'

	declare @ResponseText nvarchar(max)

	exec sp_GetHttpRequest 'https://api.n11.com/ws/productService', 'POST', 'text/xml', null, null, null,@RequestBody, @ResponseXML out 
	select @ResponseXML
end