CREATE PROCEDURE [dbo].[sp_GetHBCategories]
	@userName			nvarchar(max),
	@password			nvarchar(max),
	@currentPage		nvarchar(max)='0'
as
begin
	declare @responseData		nvarchar(max)
	declare @authorization		nvarchar(max)
	declare @urlAddress			nvarchar(max)

	select @authorization = 'Basic ' + dbo.fnBase64Encode(@userName +':' + @password)
	set @urlAddress = 'https://mpop-sit.hepsiburada.com/product/api/categories/get-all-categories?leaf=true&status=ACTIVE&available=true&page=' + @currentPage + '&size=2000&version=1'

	exec sp_GetHttpRequest @urlAddress, 'GET', 'application/json', @authorization, null, null, null, @responseData out

	select	json_value(Categories.[value], '$.categoryId') CategoryId, 
			json_value(Categories.[value], '$.parentCategoryId') ParentCategoryId, 
			json_value(Categories.[value], '$.name') CategoryName, 
			json_value(Categories.[value], '$.displayName') DisplayName
	From	OPENJSON(@responseData, '$.data') Categories
	Order By json_value(Categories.[value], '$.parentCategoryId')
	
end