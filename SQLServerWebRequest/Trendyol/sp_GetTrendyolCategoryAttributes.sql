CREATE PROCEDURE [dbo].[sp_GetTrendyolCategoryAttributes]
	@categoryId			nvarchar(max)
AS
Begin
	Declare @responseData	nvarchar(max)
	Declare @urlAddress		nvarchar(max)

	set @urlAddress = 'https://api.trendyol.com/sapigw/product-categories/' + @categoryId + '/attributes'

	exec sp_GetHttpRequest @urlAddress, 'GET', 'application/json', null, null, null, null, @responseData out

	-- Attributes --
	Select	json_value(Attributes.[value], '$.categoryId') CategoryId, 
			json_value(Attributes.[value], '$.attribute.id') AttributeId, 
			json_value(Attributes.[value], '$.attribute.name') AttributeName, 
			json_value(Attributes.[value], '$.allowCustom') AllowCustom, 
			json_value(Attributes.[value], '$.required') [Required], 
			json_value(Attributes.[value], '$.varianter') Varianter, 
			json_value(Attributes.[value], '$.slicer') Slicer 
	From	OPENJSON(@responseData, '$.categoryAttributes') Attributes
	-- /Attributes --
	-- AttributeValues --
	Select	json_value(Attributes.[value], '$.attribute.id') AttributeId, 
			json_value(AttributeValues.[value], '$.id') ValueId, 
			json_value(AttributeValues.[value], '$.name') ValueName
	From	OPENJSON(@responseData, '$.categoryAttributes') Attributes
		cross apply OPENJSON(Attributes.[value], '$.attributeValues') AttributeValues
	-- /AttributeValues --

end