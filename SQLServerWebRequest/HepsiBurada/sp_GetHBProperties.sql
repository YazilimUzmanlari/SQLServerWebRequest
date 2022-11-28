CREATE PROCEDURE [dbo].[sp_GetHBProperties]
	@userName			nvarchar(max),
	@password			nvarchar(max),
	@categoryId			nvarchar(max),
	@attributeId		nvarchar(max),
	@page				nvarchar(max)
as
begin
	declare @responseData		nvarchar(max)
	declare @authorization		nvarchar(max)
	declare @urlAddress			nvarchar(max)

	select @authorization = 'Basic ' + dbo.fnBase64Encode(@userName + ':' + @password)
	set @urlAddress = 'https://mpop-sit.hepsiburada.com/product/api/categories/' + @CategoryId + '/attribute/' + @AttributeId + '/values?page=' + @page + '&size=1000&version=4'

	exec sp_GetHttpRequest @urlAddress, 'GET', 'application/json', @authorization, null, null, null, @responseData out

	select	json_value(Properties.[value], '$.value') [Value]
	From	OPENJSON(@responseData, '$.data') Properties
end