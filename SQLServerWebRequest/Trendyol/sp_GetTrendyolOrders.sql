CREATE PROCEDURE [dbo].[sp_GetTrendyolOrders]
	@supplierId			nvarchar(max),
	@apiKey				nvarchar(max),
	@apiSecretKey		nvarchar(max),
	@page				nvarchar(max),
	@size				nvarchar(max)
as
begin
	Declare @responseData		nvarchar(max)
	declare @urlAddress			nvarchar(max)
	declare @authorization		nvarchar(max)

	select @authorization = 'Basic ' + dbo.fnBase64Encode(@apiKey + ':' + @apiSecretKey)
	
	set @urlAddress = 'https://api.trendyol.com/sapigw/suppliers/' +  @supplierId + '/orders?page=' + @page + '&size=' + @size
	exec sp_GetHttpRequest @urlAddress, 'GET', 'application/json', @authorization, null, null, null, @responseData out

	-- ORDER HEADER --
	Select	json_value(OrderHeader.[value], '$.orderNumber') OrderNumber, 
			Cast(DateAdd(SECOND, Cast(json_value(OrderHeader.[value], '$.orderDate') as bigint) /1000, '1970/1/1') as datetime) OrderDate, 
			json_value(OrderHeader.[value], '$.invoiceAddress.fullName') InvoiceAddressFullName, 
			json_value(OrderHeader.[value], '$.invoiceAddress.fullAddress') InvoiceAddressFullAddress, 
			json_value(OrderHeader.[value], '$.shipmentAddress.fullName') ShipmentAddressFullName, 
			json_value(OrderHeader.[value], '$.shipmentAddress.fullAddress') ShipmentAddressFullAddress, 
			json_value(OrderHeader.[value], '$.tcIdentityNumber') TCIdentityNumber, 
			json_value(OrderHeader.[value], '$.customerFirstName') CustomerFirstName, 
			json_value(OrderHeader.[value], '$.customerLastName') CustomerLastName, 
			json_value(OrderHeader.[value], '$.shipmentPackageStatus') ShipmentPackageStatus,
			json_value(OrderHeader.[value], '$.status') [Status], 
			json_value(OrderHeader.[value], '$.totalPrice') TotalPrice, 
			json_value(OrderHeader.[value], '$.currencyCode') CurrencyCode
	From	OPENJSON(@responseData, '$.content') OrderHeader
	-- /ORDER HEADER --
	-- Order Detail -- 
	Select	json_value(OrderHeader.[value], '$.orderNumber') OrderNumber, 
			json_value(OrderDetail.[value], '$.sku') StockCode, 
			json_value(OrderDetail.[value], '$.productName') ProductName, 
			json_value(OrderDetail.[value], '$.quantity') Quantity, 
			json_value(OrderDetail.[value], '$.price') Price 
	From	OPENJSON(@responseData, '$.content') OrderHeader
		cross apply OPENJSON(OrderHeader.[value], '$.lines') OrderDetail
	-- /Order Detail --

end