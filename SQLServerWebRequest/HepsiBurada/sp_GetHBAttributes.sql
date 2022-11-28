CREATE PROCEDURE [dbo].[sp_GetHBAttributes]
	@userName		nvarchar(max),
	 @password		nvarchar(max),
	 @categoryId	nvarchar(max)
as
begin
	Declare @responseData		nvarchar(max)
	declare @authorization		nvarchar(max)
	declare @urlAddress			nvarchar(max)

	select @authorization = 'Basic ' + dbo.fnBase64Encode(@userName + ':' + @password)
	set @urlAddress = 'https://mpop-sit.hepsiburada.com/product/api/categories/' + @categoryId + '/attributes'

	exec sp_GetHttpRequest @urlAddress, 'GET', 'application/json', @authorization, null, null, null, @responseData out

	select	'BaseAttributes' AttributeType, 
			json_value(Attributes.[value],'$.id') AttributeId, 
			json_value(Attributes.[value],'$.name') AttributeName, 
			json_value(Attributes.[value],'$.mandatory') Mandatory, 
			json_value(Attributes.[value],'$.type') [Type], 
			json_value(Attributes.[value],'$.multiValue') MultiValue
	From	OPENJSON(@responseData, '$.data.baseAttributes') Attributes
	union all
	select	'Attributes' AttributeType, 
			json_value(Attributes.[value],'$.id') AttributeId, 
			json_value(Attributes.[value],'$.name') AttributeName, 
			json_value(Attributes.[value],'$.mandatory') Mandatory, 
			json_value(Attributes.[value],'$.type') [Type], 
			json_value(Attributes.[value],'$.multiValue') MultiValue
	From	OPENJSON(@responseData, '$.data.attributes') Attributes
	union all
	select	'VariantAttributes' AttributeType, 
			json_value(Attributes.[value],'$.id') AttributeId, 
			json_value(Attributes.[value],'$.name') AttributeName, 
			json_value(Attributes.[value],'$.mandatory') Mandatory, 
			json_value(Attributes.[value],'$.type') [Type], 
			json_value(Attributes.[value],'$.multiValue') MultiValue
	From	OPENJSON(@responseData, '$.data.variantAttributes') Attributes

end