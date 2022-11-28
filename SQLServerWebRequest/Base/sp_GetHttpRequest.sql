CREATE PROCEDURE [dbo].[sp_GetHttpRequest]
	@httpUrlAddress			nvarchar(256), -- Http Url Address
	@httpMethod				nvarchar(10), -- Http Web Method (Get, Post, Delete, Put)
	@contentType			nvarchar(100), -- Content Type text/xml, application/json
	@authorization			nvarchar(max), -- Authorization Value
	@headerKey				nvarchar(max), -- Header Key
	@headerValue			nvarchar(max), -- Header Value
	@httpBody				nvarchar(max), -- Send Data
	@responseText			nvarchar(max) out -- Response Data
as
begin

	Declare @objectId		int -- Created Object Id (Token Id)
	Declare @hResult		int -- 0=> No Error

	Declare @statusCode		nvarchar(10) -- Http Request Status Code
	Declare @statusText		nvarchar(max) -- Http Request Status Text 

	exec @hResult = sp_OACreate 'Msxml2.ServerXMLHTTP.6.0', @objectId out, 1
	if @hResult <> 0 exec sp_OAGetErrorInfo @objectId

	--EXEC sp_OASetProperty @objectID, 'setTimeouts','1200000','1200000','9900000','9900000'


	exec @hResult = sp_OAMethod @objectId, 'open', null, @httpMethod, @httpUrlAddress, 0
	if @hResult <> 0 exec sp_OAGetErrorInfo @objectId

	if (Not @contentType is null)
	begin
		exec @hResult = sp_OAMethod @objectId, 'setRequestHeader', null, 'Content-Type', @contentType
		if @hResult <> 0 exec sp_OAGetErrorInfo @objectId
	end

	if (Not @authorization is null)
	begin
		exec @hresult = sp_OAMethod @objectId, 'setRequestHeader', null, 'Authorization', @authorization
		if @hResult <> 0 exec sp_OAGetErrorInfo @objectId
	end

	if ((Not @headerKey is null ) and (Not @headerValue is null))
	begin
		exec @hResult = sp_OAMethod @objectId, 'setRequestHeader', null, @headerKey, @headerValue
		if @hResult <> 0 exec sp_OAGetErrorInfo @objectId
	end

	exec @hResult = sp_OAMethod @objectId, 'send', null, @httpBody
	if @hResult <> 0 exec sp_OAGetErrorInfo @objectId

	exec sp_OAGetProperty @objectId, 'status', @statusCode out
	exec sp_OAGetProperty @objectId, 'statusText', @statusText out

	create table #responseTable(ResponseText nvarchar(max))

	Insert Into #responseTable(ResponseText)
	exec sp_OAGetProperty @objectId, 'ResponseText'

	select @responseText = ResponseText
	From #responseTable
	print @responseText
	drop table #responseTable
	exec sp_OADestroy @objectId

end