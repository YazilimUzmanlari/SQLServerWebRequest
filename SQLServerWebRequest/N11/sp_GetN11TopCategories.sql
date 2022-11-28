CREATE PROCEDURE [dbo].[sp_GetN11TopCategories]
	@apiKey			nvarchar(max),
	@apiSecretKey	nvarchar(max)
as
begin
	Declare @responseData		nvarchar(max)
	Declare @urlAddress			nvarchar(max)
	declare @requestBody		nvarchar(max)
	declare @responseXML		xml

	set @requestBody = '
	<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
		<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
			<GetTopLevelCategoriesRequest xmlns="http://www.n11.com/ws/schemas">
				<auth xmlns="">
					<appKey>' + @apiKey + '</appKey>
					<appSecret>' + @apiSecretKey + '</appSecret>
				</auth>
			</GetTopLevelCategoriesRequest>
		</s:Body>
	</s:Envelope>
	'
	set @urlAddress = 'https://api.n11.com/ws/categoryService'
	exec sp_GetHttpRequest @urlAddress, 'POST', 'text/xml', null, null, null, @requestBody, @responseData out
	set @responseXML = Cast(@responseData as xml)

	--select @responseXML

	;With XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env], 'http://www.n11.com/ws/schemas' as n3)
	select	Categories.Data.value('(id/text())[1]', 'nvarchar(max)') Id, 
			Categories.Data.value('(name/text())[1]', 'nvarchar(max)') Name
	From	@responseXML.nodes('/env:Envelope/env:Body/n3:GetTopLevelCategoriesResponse/categoryList/category') as Categories(Data)

end