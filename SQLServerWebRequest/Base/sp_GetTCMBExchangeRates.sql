CREATE PROCEDURE [dbo].[sp_GetTCMBExchangeRates]
	@date		datetime = null
AS
	declare @urlAddress		nvarchar(max)
	declare @responseText	nvarchar(max)

	if (@date is null)
	begin
		set @urlAddress = 'https://www.tcmb.gov.tr/kurlar/today.xml'
	end
	else
	begin
		set @urlAddress = 'https://www.tcmb.gov.tr/kurlar/' + format(@date, 'yyyyMM') + '/' + Format(@date, 'ddMMyyyy') + '.xml'
	end

	exec sp_GetHttpRequest @urlAddress, 'GET', 'text/xml', null, null, null, null, @responseText out

	Create table #ResponseTable(ResponseXML xml)
	
	Insert Into #ResponseTable(ResponseXML)
	Select Replace(Replace(@responseText,'<?xml version="1.0" encoding="UTF-8"?>',''),'<?xml-stylesheet type="text/xsl" href="isokur.xsl"?>','') 
	
	select	ResponseXML
	From	#ResponseTable
	
	select	b.Data.value('@Kod', 'nvarchar(5)') CurrencyCode, 
			b.Data.value('(CurrencyName/text())[1]', 'nvarchar(50)') CurrencyName, 
			Convert(datetime, b.Data.value('../@Tarih', 'nvarchar(20)'),103) [Date], 
			b.Data.value('(ForexBuying/text())[1]', 'float') ForexBuying,
			b.Data.value('(ForexSelling/text())[1]', 'float') ForexSelling,
			b.Data.value('(BanknoteBuying/text())[1]', 'float') BanknoteBuying,
			b.Data.value('(BanknoteSelling/text())[1]', 'float') BanknoteSelling
	From	#ResponseTable
		Cross apply #ResponseTable.[ResponseXML].nodes('/Tarih_Date//Currency') b(Data)
	drop table #ResponseTable
RETURN 0
