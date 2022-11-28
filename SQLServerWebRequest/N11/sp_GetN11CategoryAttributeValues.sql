CREATE PROCEDURE [dbo].[sp_GetN11CategoryAttributeValues]
	@apiKey			nvarchar(max),
	@apiSecretKey	nvarchar(max),
	@categoryId	nvarchar(max) = '1111101'
as
begin

	set nocount on;
	SET TEXTSIZE 2147483647;


	Declare @ResponseXML xml
	Declare @RequestBody nvarchar(max)	
	
	SET @ResponseXML = ''
	SET @RequestBody = ''
	select @RequestBody = '
	<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
		<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
			<GetCategoryAttributesRequest xmlns="http://www.n11.com/ws/schemas">
				<auth xmlns="">
					<appKey>' + @apiKey + '</appKey>
					<appSecret>' + @apiSecretKey + '</appSecret>
				</auth>
				<categoryId xmlns="">' + @categoryId + '</categoryId>
				<pagingData xmlns="">
					<currentPage>0</currentPage>
					<pageSize>1000</pageSize>
				</pagingData>
			</GetCategoryAttributesRequest>
		</s:Body>
	</s:Envelope>
	'
	--Select @RequestBody = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><GetTopLevelCategoriesRequest xmlns="http://www.n11.com/ws/schemas"><auth xmlns=""><appKey>' + @apiKey + '</appKey><appSecret>' + @apiSecret + '</appSecret></auth></GetTopLevelCategoriesRequest></s:Body></s:Envelope>'
	
	declare @ResponseText nvarchar(max)

	exec sp_GetHttpRequest 'https://api.n11.com/ws/categoryService', 'POST','text/xml', null, null, null,@RequestBody, @ResponseXML out 
	select @ResponseXML

	;WITH XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' as [env],'http://www.n11.com/ws/schemas' as n3 )
	Select		Coalesce(b.Data.value('(../../id/text())[1]',			'float')		,'')	AttributeId,
				Coalesce(b.Data.value('(../../name/text())[1]',			'nvarchar(max)')		,'')	AttributeName,
				Coalesce(b.Data.value('(../../mandatory/text())[1]',			'bit')		,'')	AttributeMandatory,
				Coalesce(b.Data.value('(../../multipleSelect/text())[1]',			'bit')		,'')	AttributeMultipleSelect,
				Coalesce(b.Data.value('(../../priority/text())[1]',			'float')		,'')	AttributePriority,
				Coalesce(b.Data.value('(id/text())[1]',			'float')		,'')	ValueId,
				Coalesce(b.Data.value('(name/text())[1]',			'nvarchar(max)')		,'')	Valuename
	From @ResponseXML.nodes('/env:Envelope/env:Body/n3:GetCategoryAttributesResponse/category/attributeList/attribute/valueList/value') as b(DATA)
	order by Coalesce(b.Data.value('(name/text())[1]',			'nvarchar(max)')		,'')


end