CREATE PROCEDURE [dbo].[sp_GetTrendyolProducts]
	@supplierId			nvarchar(max),
	@apiKey				nvarchar(max),
	@apiSecretKey		nvarchar(max),
	@page				nvarchar(max),
	@size				nvarchar(max)
AS
begin
	Declare @responseData	nvarchar(max)
	Declare @authorization	nvarchar(max)
	Declare @urlAddress		nvarchar(max)

	select @authorization = 'Basic ' + dbo.fnBase64Encode(@apiKey + ':' + @apiSecretKey)

	set @urlAddress = 'https://api.trendyol.com/sapigw/suppliers/' + @supplierId + '/products?page=' + @page + '&size=' + @size 

	exec sp_GetHttpRequest @urlAddress, 'GET', 'application/json', @authorization, null, null, null, @responseData out

	select	json_value(products.[value], '$.stockCode') StockCode, 
			json_value(products.[value], '$.title') Title, 
			json_value(products.[value], '$.categoryName') CategoryName, 
			json_value(products.[value], '$.quantity') Quantity, 
			json_value(products.[value], '$.stockUnitType') StockUnitType, 
			json_value(products.[value], '$.salePrice') SalePrice, 
			json_value(products.[value], '$.approved') Approved, 
			json_value(products.[value], '$.barcode') Barcode
	From	OPENJSON(@responseData, '$.content') products
	order by json_value(products.[value], '$.categoryName')

end