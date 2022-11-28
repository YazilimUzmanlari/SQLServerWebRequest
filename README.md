# SQLServerWebRequest
Bu eğitim serimizde farklı web sitelerine sorgular gönderip dönen değerleri nasıl işleyeceğimizi inceleyeceğiz. Bu işlemleri yapabilmek için bir stored procedure oluşturacağız. Bu stored procedure içerisinde HTTP OLE nesnesi oluşturup ihtiyacımıza uygun parametreler atadıktan sonra HTTP nesnemizin dönen değerlerini nasıl alacağımıza inceleyebilirsiniz. 

SQL Sorgumuzta Msxml2.ServerXMLHttp.6.0 OLE nesnesini kullanacağız. Bu nesneyi kullanabilmek için SQL Server da aşağıdaki komutlarla ayarlarımızı yapmamız gerekiyor.

```
Use master
go
sp_configure 'Ole Automation Procedures', 1
go
reconfigure;
sp_configure 'show advanced options',1
go 
```

Web sitelerine sorgularımızı yapabilmek için genel ihtiyaçlarımıza cevap verebilecek şekilde bir base procedure oluşturacağız. Bu procedure dışarıdan bazı parametreler alarak bu parametrelere göre belirttiğimiz web adresine request atıp dönen sonucu dışarı verecek şekilde yapılandıracağız. 

sp_GetHttpRequest adında bir stored procedure oluşturduk. Bu stored procedure httpUrlAddress parametresinde vereceğimiz web adresine sorgu atacak. Sorguyu httpMethod da belirttiğimiz methoda göre istek atacak. Bunlar bildiğimiz gibi Get, Post, Delete, Put değerlerinden oluşuyor. Web sitesine sorgu atarken sorgumuzun header kısmında ihtiyaç duyabileceğimiz contenttype, authorization, headerkey, headervalue değerlerini yine parametremiz ile web sitesine göndermemiz gereken bilgileri de httpbody kısmında vereceğiz. Dönen değeri de responsetext parametresiyle dışarı veriyor olacağız.

```
    @httpUrlAddress  nvarchar(256), -- Http Url Address
    @httpMethod  nvarchar(10), -- Http Web Method (Get, Post, Delete, Put)
    @contentType  nvarchar(100), -- Content Type text/xml, application/json
    @authorization  nvarchar(max), -- Authorization Value
    @headerKey  nvarchar(max), -- Header Key
    @headerValue  nvarchar(max), -- Header Value
    @httpBody  nvarchar(max), -- Send Data
    @responseText  nvarchar(max) out -- Response Data
```
Stored Procedure içerisinde kullanabileceğimiz 4 ayrı değişken tanımlıyoruz. Bunlar; Oluşturduğumuz OLE nesnesini handle edebilmemiz için kullanacağımız objectId ve OLE Nesnesini oluştururken veya değerler atarken işlemin başarılı bir şekilde oluştuğunu kontrol edebileceğimiz hResult Oluşturduğumuz nesneyi send ile gönderdikten sonra durumunu sorgulayacağımız statusCode ve statusText 


Sp_OACreate ile MSXML2.ServerXMLHttp6.0 OLE nesnemizi oluşturup değerini objectId ye atıyoruz. Nesne başarılı bir şekilde oluştuysa @hResult değeri sıfır olarak dönecektir. @hResult değeri sıfırdan farklı ise hata mesajı ile işlemimizi sonlandıracağız. Oluşturduğumuz nesneye sp_OAMethod ile httpMethod ve httpUrlAddress bilgilerini veriyoruz. 
```
Declare @objectId int -- Created Object Id (Token Id)
Declare @hResult int -- 0=> No Error

Declare @statusCode nvarchar(10) -- Http Request Status Code
Declare @statusText nvarchar(max) -- Http Request Status Text 

exec @hResult = sp_OACreate 'Msxml2.ServerXMLHTTP.6.0', @objectId out, 1
if @hResult <> 0 exec sp_OAGetErrorInfo @objectId
```
sp_OAMethod
Http nesnemizi oluşturduk. Bu nesnemize bir takım parametreler girebilmek için sp_OAMethod kullanacağız. Bu parametreleri oluşturduğumuz nesneye open, setRequestHeader, send değerlerini kullanarak vereceğiz. İlk olarak http nesnemizi açmamız gerekiyor. Ardından Http Requestimizin header kısmına gereken parametreleri ekleyebiliriz. 

open : Bu komut ile Http nesnemizi açıyoruz. Bu nesnenin aldığı parametreler içerisinde WebMethod (GET, POST, UPDATE, DELET vb. ) ve URL Adresi bilgilerini veriyoruz. 
setRequestHeader : Bu komut ile request imizin header bilgilerini ard arda verebiliriz. Header tısmına Content Type, Authorization vb. bilgileri http nesnemize verebiliriz.
send : Http sorgumuzda header bilgilerini nesnemize ekledikten sonra send komutu ile sorgumuzu tamamlayabiliriz. Send komutu ile aynı zamanda body kısmında gönderebileceğimiz bilgileri de gönderebiliyoruz. 

sp_GetProperty
Http nesnemiz ile sorgumuzu web sitesine gönderdik. Şimdi ise dönen değerleri sp_GetProperty ile alarak gerekli işlemleri yapabiliriz. 

Status ve statustext web sitesinin bize gönderdiği durum bilgilerini içerir. Status değeri 200 ise işlem başarılı anlamına gelir. Burada sizler dilerseniz status  değerinin 200 e eşit olup olmadığını kontrol edebilirsiniz. 


ResponseText değerini alabilmek için temp table oluşturmamız gerekiyor.  ResponseTable adında responseText alanına sahip bir temp table oluşturuyoruz. Bu tabloyu oluşturduktan sonra Insert Into ile web sitesinden gelen responseText değerini  tablomuza ekliyoruz. Ardından select ile yukarıda parametrelerde tanımladığımız responsetext değerine eşitliyoruz. 

Status - StatusText : Belirttiğimiz url adresine request çektikten sonra dönen durum değerini status ile alabiliyoruz. Bu Web Status değerleri (200-OK, 404-Not Found, 500 Internal Server Error vb. ) 
ResponseText: Sorguladığımız url adresinden dönen bilgileri ResponseText ile alabiliriz. Dönen sonucun içeriğine (Xml, Json, text vb. ) göre bilgileri parse ederek ilgili tablolarımıza insert-update vb işlemleri gerçekleştirebiliriz. 
