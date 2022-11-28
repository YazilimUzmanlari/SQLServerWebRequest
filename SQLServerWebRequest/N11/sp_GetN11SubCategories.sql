CREATE PROCEDURE [dbo].[sp_GetN11SubCategories]
	@apiKey				nvarchar(max),
	@apiSecretKey		nvarchar(max),
	@parentCategoryId	nvarchar(max)
as
begin
	declare @responseData		nvarchar(max)
	declare @urlAddress			nvarchar(max)
	declare @requestBody		nvarchar(max)
	declare @responseXML		xml

	set @requestBody = N'
	<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
		<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
			<GetSubCategoriesRequest xmlns="http://www.n11.com/ws/schemas">
				<auth xmlns="">
					<appKey>' + @apiKey + '</appKey>
					<appSecret>' + @apiSecretKey + '</appSecret>
				</auth>
				<categoryId xmlns="">' + @parentCategoryId + '</categoryId>
			</GetSubCategoriesRequest>
		</s:Body>
	</s:Envelope>	
	'
	set @urlAddress = 'https://api.n11.com/ws/categoryService'
	exec sp_GetHttpRequest @urlAddress, 'POST', 'text/xml', null, null, null, @requestBody, @responseData out

	set @responseXML = Cast(@responseData as xml)
	select @responseXML
	return 
	;With XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env], 'http://www.n11.com/ws/schemas' as n3)
	Select	SubCategories.Data.value('(id/text())[1]', 'nvarchar(max)') Id, 
			SubCategories.Data.value('(name/text())[1]', 'nvarchar(max)') Name
	From	@responseXML.nodes('/env:Envelope/env:Body/n3:GetSubCategoriesResponse/category/subCategoryList/subCategory') as SubCategories(Data)

end