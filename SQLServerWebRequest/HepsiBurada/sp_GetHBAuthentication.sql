CREATE PROCEDURE [dbo].[sp_GetHBAuthentication]
	@userName		nvarchar(max),
	@password		nvarchar(max),
	@bearer			nvarchar(max) out
as
begin

	set nocount on;
	SET TEXTSIZE 2147483647;

	Declare @Url nvarchar(max)
	Declare @ResponseXML xml
	Declare @RequestBody nvarchar(max)	
	
	SET @ResponseXML = ''
	SET @RequestBody = '{
    "username": "' + @userName + '",
   "password": "' + @password + '",
   "authenticationType": "INTEGRATOR"
}'

	set @Url = 'https://mpop-sit.hepsiburada.com/api/authenticate'
				
	declare @ResponseText nvarchar(max)

	exec sp_GetHttpRequest @Url, 'POST', 'application/json', null, null, null,@RequestBody, @ResponseText out 
	select @bearer = Replace(Replace(@ResponseText,'{"id_token":"',''),'"}','') 
end