CREATE PROCEDURE [dbo].[sp_GetN11Attributes]
	@apiKey			nvarchar(max),
	@apiSecretKey	nvarchar(max),
	@categoryId		nvarchar(max)
as
begin
	declare @responseData		nvarchar(max)
	declare @urlAddress			nvarchar(max)
	declare @requestBody		nvarchar(max)
	declare @responseXML		xml

	set @requestBody = N'
	<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
		<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
			<GetCategoryAttributesRequest xmlns="http://www.n11.com/ws/schemas">
				<auth xmlns="">
					<appKey>' + @apiKey + '</appKey>
					<appSecret>' + @apiSecretKey + '</appSecret>
				</auth>
				<categoryId xmlns="">' + @categoryId + '</categoryId>
				<pagingData xmlns="">
					<currentPage>1</currentPage>
					<pageSize>100</pageSize>
				</pagingData>
			</GetCategoryAttributesRequest>
		</s:Body>
	</s:Envelope>
	'

	set @urlAddress = 'https://api.n11.com/ws/categoryService'
	exec sp_GetHttpRequest @urlAddress, 'POST', 'text/xml', null, null, null, @requestBody, @responseData out

	set @responseXML = Cast(@responseData as xml)
	select @responseXML
	-- Attributes --
	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as n3 )
	select	Attributes.Data.value('(id/text())[1]', 'nvarchar(max)') Id, 
			Attributes.Data.value('(name/text())[1]', 'nvarchar(max)') Name, 
			Attributes.Data.value('(mandatory/text())[1]', 'nvarchar(max)') Mandatory, 
			Attributes.Data.value('(priority/text())[1]', 'nvarchar(max)') Priority
	From	@responseXML.nodes('/env:Envelope/env:Body/n3:GetCategoryAttributesResponse/category/attributeList/attribute') as Attributes(Data)
	-- /Attributes --
	-- AttributeValues --
	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as n3 )
	Select	AttributeValues.Data.value('(../../id/text())[1]', 'nvarchar(max)') AttributeId,
			AttributeValues.Data.value('(id/text())[1]', 'nvarchar(max)') ValueId, 
			AttributeValues.Data.value('(name/text())[1]', 'nvarchar(max)') ValueName
	From	@responseXML.nodes('/env:Envelope/env:Body/n3:GetCategoryAttributesResponse/category/attributeList/attribute/valueList/value') AttributeValues(Data)
	-- /AttributeValues --
end