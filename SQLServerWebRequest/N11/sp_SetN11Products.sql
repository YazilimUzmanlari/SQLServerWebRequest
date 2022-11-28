CREATE PROCEDURE [dbo].[sp_SetN11Products]
	@ItemCode			nvarchar(max), 
	@Title				nvarchar(max), 
	@SubTitle			nvarchar(max), 
	@Description		nvarchar(max), 
	@CategoryId			nvarchar(max),
	@Price				nvarchar(max), 
	@AttributeName		nvarchar(max),
	@AttributeValue		nvarchar(max), 
	@Images				nvarchar(max),
	@Quantity			nvarchar(max)
as
begin


	Declare @apiKey			nvarchar(max)
	Declare	@apiSecretKey	nvarchar(max)
	Declare @saleStartDate	nvarchar(max)
	Declare @saleEndDate	nvarchar(max)
	select @saleStartDate = FORMAT (getdate(), 'dd/MM/yyyy')
	SELECT @saleEndDate = FORMAT (DATEADD(year, 3, getdate()), 'dd/MM/yyyy') 

	select	Top 1
			@apiKey = ApiKey,
			@apiSecretKey = ApiSecretKey
	From	Communications
	Where	CommunicationType= 6 and
		Name = 'N11'

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
      <sch:SaveProductRequest>
         <auth>
			<appKey>' + @apiKey + '</appKey>
			<appSecret>' + @apiSecretKey + '</appSecret>
         </auth>
         <product>
            <productSellerCode>' + @ItemCode + '</productSellerCode>
            <title>' + @Title + '</title>
            <subtitle>' + @SubTitle + '</subtitle>
            <description>' + @Description + '</description>
            <category>
               <id>' + @CategoryId + '</id>
            </category>
            <specialProductInfoList/>
            <price>' + @Price + '</price> 
             <domestic>true</domestic>
            <currencyType>2</currencyType>
            ' + @Images + '
            <approvalStatus>1</approvalStatus>
            <attributes>
               <attribute>
                  <name>' + @AttributeName + '</name>
                  <value>' + @AttributeValue + '</value>
               </attribute>
            </attributes>
            <saleStartDate>' + @saleStartDate  + '</saleStartDate>
            <saleEndDate>' + @saleEndDate + '</saleEndDate>
            <productionDate>' + @saleStartDate  + '</productionDate>
            <expirationDate/>
            <productCondition>1</productCondition>
            <preparingDay>1</preparingDay>
            <discount>
               <startDate/>
               <endDate/>
               <type/>
               <value/>
            </discount>
            <shipmentTemplate>AGT</shipmentTemplate>
            <stockItems>
               <!--1 or more repetitions:-->
               <stockItem>
                  <bundle/>
                  <mpn/>
                  <gtin/>
                  <oem></oem>
				  <n11CatalogId></n11CatalogId>
                  <quantity>' + @Quantity  + '</quantity>
                  <sellerStockCode/></sellerStockCode>
                  <attributes/>
                  <optionPrice/>
               </stockItem>
            </stockItems>
            <groupAttribute></groupAttribute>
            <groupItemCode></groupItemCode>
            <itemName></itemName>
         </product>
      </sch:SaveProductRequest>
   </soapenv:Body>
</soapenv:Envelope>
'

	declare @ResponseText nvarchar(max)

	exec sp_GetHttpRequest 'https://api.n11.com/ws/productService', 'POST', 'text/xml', null, null, null, @RequestBody, @ResponseXML out 

	select @ResponseXML

end