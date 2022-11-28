CREATE PROCEDURE [dbo].[sp_GetTrendyolCategories]
	
AS
begin
	Declare @responseData nvarchar(max)

	exec sp_GetHttpRequest 'https://api.trendyol.com/sapigw/product-categories', 'GET', 'application/json', null, null, null, null, @responseData out

	select	*
	From	dbo.fnGetNestedCategories(@responseData)
	order By ParentId, Id
end