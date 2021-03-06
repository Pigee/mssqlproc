USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_OWN_STATIC]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_OWN_STATIC]
@OWN_DATE VARCHAR(20), --‘2016-05’
@PC_TYPE VARCHAR(20) -- 'XJ','TS','QB'现金,托收,全部
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='#temp_owstatic')
 DROP TABLE #temp_owstatic;

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='#temp_restatic')
 DROP TABLE #temp_restatic;




SELECT  T3.WATERT_NAME,t1.watert_no userb_yhlx,CAST(CAST(t1.DEBTL_YEAR AS VARCHAR)+'-'+CAST(T1.DEBTL_MON AS VARCHAR) +'-1' as datetime) ZD_DATE ,t1.USERB_KH,t1.PAY_TAG,t1.WATERP_QAN,t1.DEBTL_STOTAL,t1.DEBTL_ATOTAL,t1.DEBTL_ZNJ,t1.PAY_DATE INTO #temp_owstatic FROM FH_DEBTOWNHIS T1,FH_WATERTYPE T3 WHERE t1.watert_no = t3.watert_no and CAST(CAST(DEBTL_YEAR AS VARCHAR)+'-'+CAST(DEBTL_MON AS VARCHAR) +'-1' as datetime) <= CAST(@OWN_DATE + '-1' AS DATETIME)



IF @PC_TYPE = 'XJ'
  BEGIN
      DELETE FROM #temp_owstatic where userb_kh in (select userb_kh from fh_userbase  where USERB_SFFS = 'sffs01');
  END

IF @PC_TYPE = 'TS'
  BEGIN
      DELETE FROM #temp_owstatic where userb_kh in (select userb_kh from fh_userbase  where USERB_SFFS <> 'sffs01');
  END

--SELECT * FROM #temp_owstatic WHERE PAY_DATE IS NOT NULL;

CREATE table #temp_restatic (price_type varchar(20),price_name varchar(20),item varchar(20),last_total varchar(20),by_total varchar(20),byxz_total varchar(20),znj_total varchar(20),s_total varchar(20),byjq varchar(20));

insert into #temp_restatic (price_name,price_type,item) select distinct WATERT_NAME,USERB_YHLX,'ACC_TOTAL' from #temp_owstatic;
insert into #temp_restatic (price_name,price_type,item) select distinct WATERT_NAME,USERB_YHLX,'BWATER_QAN' from #temp_owstatic;
insert into #temp_restatic (price_name,price_type,item) select distinct WATERT_NAME,USERB_YHLX,'CASH_TOTAL' from #temp_owstatic;

insert into #temp_restatic (price_name,price_type,item) values ('总数','zs','ACC_TOTAL');
insert into #temp_restatic (price_name,price_type,item) values ('总数','zs','BWATER_QAN');
insert into #temp_restatic (price_name,price_type,item) values ('总数','zs','CASH_TOTAL');

UPDATE #TEMP_RESTATIC SET last_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME) GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total';
UPDATE #TEMP_RESTATIC SET last_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(waterp_qan) ltotal from #temp_owstatic WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME) GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET last_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(DEBTL_STOTAL) ltotal from #temp_owstatic WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME) GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'CASH_total';

UPDATE #TEMP_RESTATIC SET by_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic WHERE  ZD_DATE = CAST(@OWN_DATE + '-1' AS DATETIME) GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total';
UPDATE #TEMP_RESTATIC SET by_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(waterp_qan) ltotal from #temp_owstatic WHERE  ZD_DATE = CAST(@OWN_DATE + '-1' AS DATETIME) GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET by_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(DEBTL_STOTAL) ltotal from #temp_owstatic WHERE  ZD_DATE = CAST(@OWN_DATE + '-1' AS DATETIME) GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'CASH_total';

UPDATE #TEMP_RESTATIC SET byxz_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic WHERE convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) =  CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total';
UPDATE #TEMP_RESTATIC SET byxz_total  = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(waterp_qan) ltotal from #temp_owstatic WHERE convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2'  GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET byxz_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(DEBTL_ATOTAL) ltotal from #temp_owstatic WHERE convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2'  GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'CASH_total';

--UPDATE #TEMP_RESTATIC SET znj_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total';
--UPDATE #TEMP_RESTATIC SET znj_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(waterp_qan) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2'  GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET znj_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(DEBTL_ZNJ) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2'  GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'CASH_total';

--UPDATE #TEMP_RESTATIC SET s_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total';
--UPDATE #TEMP_RESTATIC SET s_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(waterp_qan) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2'  GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET s_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(DEBTL_STOTAL) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2'  GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'CASH_total';

UPDATE #TEMP_RESTATIC SET byjq = isnull(cast(last_total as money),0) + isnull(cast(by_total as money),0) - isnull(cast(byxz_total as money),0) where price_type <> 'zs' and item = 'CASH_total';--cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic  where convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total'; --WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag  in ('0','1')
UPDATE #TEMP_RESTATIC SET byjq = isnull(cast(last_total as int),0) + isnull(cast(by_total as int),0) - isnull(cast(byxz_total as int),0) where price_type <> 'zs' and item <> 'CASH_total';--cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic  where convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total'; --WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag  in ('0','1')
--UPDATE #TEMP_RESTATIC SET byjq = -- cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(DEBTL_STOTAL) ltotal from #temp_owstatic  where convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'CASH_total';

--------------------------------------------------汇总

UPDATE #TEMP_RESTATIC SET last_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select count(*) ltotal from #temp_owstatic WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME)) t2 where t1.price_type = 'zs' and t1.item = 'acc_total';
UPDATE #TEMP_RESTATIC SET last_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select sum(waterp_qan) ltotal from #temp_owstatic WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME)) t2 where t1.price_type = 'zs' and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET last_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select sum(DEBTL_STOTAL) ltotal from #temp_owstatic WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME)) t2 where t1.price_type = 'zs' and t1.item = 'CASH_total';

UPDATE #TEMP_RESTATIC SET by_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select count(*) ltotal from #temp_owstatic WHERE  ZD_DATE = CAST(@OWN_DATE + '-1' AS DATETIME)) t2 where t1.price_type = 'zs' and t1.item = 'acc_total';
UPDATE #TEMP_RESTATIC SET by_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select sum(waterp_qan) ltotal from #temp_owstatic WHERE  ZD_DATE = CAST(@OWN_DATE + '-1' AS DATETIME)) t2 where t1.price_type = 'zs' and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET by_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select sum(DEBTL_STOTAL) ltotal from #temp_owstatic WHERE  ZD_DATE = CAST(@OWN_DATE + '-1' AS DATETIME)) t2 where t1.price_type = 'zs' and t1.item = 'CASH_total';

UPDATE #TEMP_RESTATIC SET byxz_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select count(*) ltotal from #temp_owstatic WHERE convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) =  CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2') t2 where t1.price_type = 'zs' and t1.item = 'acc_total';
UPDATE #TEMP_RESTATIC SET byxz_total  = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select sum(waterp_qan) ltotal from #temp_owstatic WHERE convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2') t2 where t1.price_type = 'zs' and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET byxz_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select sum(DEBTL_ATOTAL) ltotal from #temp_owstatic WHERE convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2') t2 where t1.price_type = 'zs' and t1.item = 'CASH_total';

--UPDATE #TEMP_RESTATIC SET znj_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total';
--UPDATE #TEMP_RESTATIC SET znj_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(waterp_qan) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2'  GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET znj_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select sum(DEBTL_ZNJ) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2') t2 where t1.price_type = 'zs' and t1.item = 'CASH_total';

--UPDATE #TEMP_RESTATIC SET s_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total';
--UPDATE #TEMP_RESTATIC SET s_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(waterp_qan) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2'  GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'BWATER_QAN';
UPDATE #TEMP_RESTATIC SET s_total = cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select sum(DEBTL_STOTAL) ltotal from #temp_owstatic WHERE  convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' ) t2 where t1.price_type = 'zs' and t1.item = 'CASH_total';

UPDATE #TEMP_RESTATIC SET byjq = isnull(cast(last_total as money),0) + isnull(cast(by_total as money),0) - isnull(cast(byxz_total as money),0) where price_type = 'zs' and item = 'CASH_total';--cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic  where convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total'; --WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag  in ('0','1')
UPDATE #TEMP_RESTATIC SET byjq = isnull(cast(last_total as int),0) + isnull(cast(by_total as int),0) - isnull(cast(byxz_total as int),0) where price_type = 'zs' and item <> 'CASH_total';--cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,count(*) ltotal from #temp_owstatic  where convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'acc_total'; --WHERE  ZD_DATE < CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag  in ('0','1')
--UPDATE #TEMP_RESTATIC SET byjq = -- cast(t2.ltotal as varchar) from #TEMP_RESTATIC t1,(select userb_yhlx,sum(DEBTL_STOTAL) ltotal from #temp_owstatic  where convert(varchar(20),dateadd(d,-day(PAY_DATE)+1,PAY_DATE),23) = CAST(@OWN_DATE + '-1' AS DATETIME) and pay_tag = '2' GROUP BY userb_yhlx) t2 where t1.price_type = t2.userb_yhlx and t1.item = 'CASH_total';

------------------------------------置0
UPDATE #TEMP_RESTATIC SET last_total = '0'  where last_total is null;
UPDATE #TEMP_RESTATIC SET by_total = '0'  where by_total is null;
UPDATE #TEMP_RESTATIC SET byxz_total = '0'  where byxz_total is null;

-------------------------输出---------------------------
 SELECT * FROM #temp_restatic ORDER BY PRICE_type,ITEM;

END
GO
