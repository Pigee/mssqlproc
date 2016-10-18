
--########################    FH_VOLUME   慎重TRUNCATE  #######################################################

INSERT INTO [jjwater].[dbo].[FH_VOLUME] ([VOLUME_ID], [VOLUME_NO], [VOLUME_NAME], [VOLUME_TYPE], [AREA_NO], [VOLUME_CBTYPE], [VOLUME_CBWAY], [VOLUME_MCOUNT], [VOLUME_CBDAY], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [STEP_LEN], [CB_HOUR]) 
SELECT NEWID(), XH, xhm, 'bclx02',null, 'cblx03', 'cbfs03', NULL, '6', NULL, getDATE(), '1', GETDATE(), '100', '1' from jwater.DBO.XHK;
--------------------
UPDATE [jjwater].[dbo].[FH_VOLUME] SET VOLUME_MCOUNT = B.MCOUNT FROM [jjwater].[dbo].[FH_VOLUME] A,(SELECT XH,COUNT(*) MCOUNT FROM jwater.DBO.USERBASE GROUP BY XH) B where A.VOLUME_NO = B.XH;

--########################    FH_BANK      #######################################################

INSERT INTO [jjwater].[dbo].[FH_BANK] ([BANK_ID], [BANK_NO], [BANK_SUPERNO], [BANK_NAME], [BANK_ADDR], [BANK_ADDRX], [BANK_ADDRY], [BANK_KHH]) 
SELECT NEWID(), BANKID, NULL, BANKNAME, NULL, NULL, NULL, BANKDM FROM jwater.dbo.BANK;

------################################CZY SYS_USER###################
INSERT INTO [jjwater].[dbo].[sys_user] ([USER_ID], [USERNAME], [NAME], [JMED], [JMZED], [YJMED]) 
SELECT ID,ID,NAME,JMED,JMZED,YJMED FROM jwater.dbo.czy;
 

--######################  FH_USERBASE      #####################################
truncate table [jjwater].[dbo].[FH_USERBASE];

INSERT INTO [jjwater].[dbo].[FH_USERBASE] ([USERBASE_ID], [USERB_HH], [USERB_KH], [USERB_HM], [USERB_CLASSIFY], [VOLUME_NO], [USERB_JJBH], [USERB_JBH], [USERB_LHRQ], [USERB_AZRQ], [USERB_DH], [USERB_LXR], [USERB_SFFS], [USERB_TOTAL], [USERB_SQDS], [USERB_BQDS], [USERB_IDNO], [USERB_ZZS], [USERB_ZZSH], [USERB_BTBZ], [USERB_BTRQ], [USERB_YSXZ], [USERB_YHLX], [USERB_CUP], [USERB_HHID], [USERB_LEVEL], [ISCHARGING], [SUPER_KH], [USERB_SBBH], [USERB_HTH], [USERB_BZ], [USERB_XQBH], [USERB_CJJBH], [USERB_MT], [USERB_AZR], [USERB_ADDR], [IS_ENABLED], [USERB_CBBZ], [USERB_GROUP])
 SELECT  NEWID(),HH,KH,HM,'yhfl01',XH,NULL,jbh,lhrq,azrq,dh,lxr,sffs,'1',NULL,NULL,id,zzs,zzsh,btbz,btrq,null,null,null,hjlx,null,'1',null,sbbh,hth,bz,xqbh,cjjbh,mt,azr,null,'1',null,null FROM [jwater].[dbo].[USERBASE];
-----------------------------------------------
 -----------------------------------------------
 UPDATE [jjwater].[dbo].FH_USERBASE SET USERB_SQDS = B.syds,USERB_BQDS = B.byds FROM [jjwater].[dbo].[FH_USERBASE] A,jwater.dbo.w_history2016 B WHERE cast(right(B.km,2) as int) = month(getdate())-1 AND A.USERB_KH = B.KH;
----------------------------
UPDATE [jjwater].[dbo].[FH_USERBASE] SET SEASON_TAG = B.jjbz,LADDER_TAG = b.jtbz,USERB_ADDR = B.DZ,USERB_YHLX = B.lb,USERB_YHDM = B.DLYHDM,BANK_NUMBER = B.dlyhsh, FIRST_TAG = B.YCBZ,BANK_TABNO = B.dlyhgyh,BASICTON_QAN = b.cesl,BASICTON_TAG = CASE WHEN b.cesl > 0 THEN 1 ELSE 0 END,FREEPULL_TAG =b.jpbz FROM [jjwater].[dbo].[FH_USERBASE] A,[jwater].[dbo].[waterused] B where A.userb_kh = B.kh;

-------------------------晋江水厂------------------------------
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '01',USERB_YHLX = '0101' WHERE USERB_YHLX = '1';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '01',USERB_YHLX = '0102' WHERE USERB_YHLX = '2';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '01',USERB_YHLX = '0103' WHERE USERB_YHLX = '3';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0201' WHERE USERB_YHLX = '4';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '03',USERB_YHLX = '0301' WHERE USERB_YHLX = '5';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '03',USERB_YHLX = '0303' WHERE USERB_YHLX = '6';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '03',USERB_YHLX = '0304' WHERE USERB_YHLX = '7'; 
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0204' WHERE USERB_YHLX = '8';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '04',USERB_YHLX = '0406' WHERE USERB_YHLX = '9';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '04',USERB_YHLX = '0401' WHERE USERB_YHLX = '10';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '04',USERB_YHLX = '0402' WHERE USERB_YHLX = '11';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '04',USERB_YHLX = '0403' WHERE USERB_YHLX = '12';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '04',USERB_YHLX = '0404' WHERE USERB_YHLX = '13';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0202' WHERE USERB_YHLX = '14';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0218' WHERE USERB_YHLX = '15';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '03',USERB_YHLX = '0305' WHERE USERB_YHLX = '16';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '04',USERB_YHLX = '0407' WHERE USERB_YHLX = '17';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '03',USERB_YHLX = '0302' WHERE USERB_YHLX = '18';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '04',USERB_YHLX = '0405' WHERE USERB_YHLX = '19';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0203' WHERE USERB_YHLX = '20';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0209' WHERE USERB_YHLX = '21';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0214' WHERE USERB_YHLX = '22';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0205' WHERE USERB_YHLX = '23';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0210' WHERE USERB_YHLX = '24';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0215' WHERE USERB_YHLX = '25';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0206' WHERE USERB_YHLX = '26';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0207' WHERE USERB_YHLX = '27';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0211' WHERE USERB_YHLX = '28';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0216' WHERE USERB_YHLX = '29';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0208' WHERE USERB_YHLX = '30';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0212' WHERE USERB_YHLX = '31';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0217' WHERE USERB_YHLX = '32';
UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_YSXZ = '02',USERB_YHLX = '0213' WHERE USERB_YHLX = '33';


----------------综合价格-------------------------------------
 UPDATE [jjwater].[dbo].[FH_USERBASE] SET USERB_CUP = B.watert_cup FROM [JJWATER].[dbo].[FH_USERBASE] A,[jjwater].[dbo].[FH_WATERTYPE] B WHERE A.USERB_YHLX = B.WATERT_NO;
 UPDATE jjwater.dbo.FH_USERBASE SET USERB_SFFS = 'sffs01' where userb_sffs = '1';
UPDATE jjwater.dbo.FH_USERBASE SET USERB_SFFS = 'sffs04' where userb_sffs = '4';
UPDATE jjwater.dbo.FH_USERBASE SET IS_ENABLED='0' WHERE VOLUME_NO='9002';
UPDATE jjwater.dbo.FH_USERBASE SET USERB_HBRQ = T2.HBRQ FROM jjwater.dbo.FH_USERBASE T1,jwater.dbo.hbk t2 where t1.userb_kh = t2.KH1;


-- ######################   FH_WATERMETER    #####################################
truncate table [jjwater].[dbo].[FH_WATERMETER];

 INSERT INTO [jjwater].[dbo].[FH_WATERMETER] ([WATERMETER_ID], [USERB_KH], [WATERM_NO], [METERC_CALIBRE], [WATERM_STYLE], [WATERM_TYPE], [WATERM_ADDR], [WATERM_AZRQ], [WATERM_X], [WATERM_Y], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [WATERM_ENABLED], [LASTCAL_DATE], [WATERM_REPDATE], [WATERM_AZR])
SELECT NEWID(),KH,TABno,tablen,tabstyle,NULL,NULL,azrq,NULL,NULL,NULL,getdate(),NULL,getdate(),'1',NULL,NULL,azr from jwater.dbo.userbase;
---------------------------------------------
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_ADDR = B.DZ FROM [jjwater].[dbo].[FH_WATERMETER] A,[jwater].[dbo].[WATERUSED] B where A.userb_kh = B.kh;

UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs01' where WATERM_STYLE = '1';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs02' where WATERM_STYLE = '2';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs03' where WATERM_STYLE = '3';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs04' where WATERM_STYLE = '4';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs05' where WATERM_STYLE = '5';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs06' where WATERM_STYLE = '6';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs07' where WATERM_STYLE = '7';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs08' where WATERM_STYLE = '8';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs09' where WATERM_STYLE = '9';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs10' where WATERM_STYLE = '10';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs11' where WATERM_STYLE = '11';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs12' where WATERM_STYLE = '12';
UPDATE [jjwater].[dbo].[FH_WATERMETER] SET WATERM_STYLE = 'bs12' where WATERM_STYLE = '13';

------------------更新换表数据---------------------------
update jjwater.dbo.FH_WATERMETER set waterm_no = t2.tabno from jjwater.dbo.FH_WATERMETER t1,jwater.dbo.userbase t2 where t1.userb_kh = t2.kh

--######################################FH_METERHIS##########################################
truncate table [jjwater].[dbo].[FH_METERHIS];

INSERT INTO [jjwater].[dbo].[FH_METERHIS] ([METERH_ID], [USERB_KH], [USERB_HM], [USERB_ADDR], [VOLUME_NO], [WATERM_OLDNO], [WATERM_NEWNO], [APPLY_DATE], [INSTALL_DATE], [METERH_WATERQAN], [METERH_COST], [WATERM_OLDQAN],[WATERM_NEWQAN], [METERH_REASON], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [WATERM_LASTQAN], [WATERH_USERID], [WATERH_DATE], [BILL_YEAR], [BILL_MONTH], [WATERH_TYPE], [CHECK_REMARK], [OLDMETER_DAY], [METERC_CALIBRE], [WATERM_STYLE], [WATERM_TYPE],[METERH_CONTENT]) 
SELECT NEWID(),KH1,NULL,NULL,XH1,null,BH,SQRQ,HBRQ,hbsl1,glf1,hbzd,hbqd,hbyy,'1',getdate(),null,null,hbzd-hbsl1,null,hbrq,year,mont,'hblx01',null,null,bj,bs,null,tonext FROM jwater.dbo.HBK;
UPDATE [jjwater].[dbo].[FH_METERHIS] SET USERB_HM = T2.USERB_HM,USERB_ADDR = T2.USERB_ADDR FROM [jjwater].[dbo].[FH_METERHIS] T1,[jjwater].[dbo].[FH_USERBASE] T2 WHERE T1.USERB_KH = T2.USERB_KH;

UPDATE [jjwater].[dbo].FH_METERHIS SET METERH_REASON='坏' WHERE METERH_REASON='7';

UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs01' where WATERM_STYLE = '1';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs02' where WATERM_STYLE = '2';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs03' where WATERM_STYLE = '3';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs04' where WATERM_STYLE = '4';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs05' where WATERM_STYLE = '5';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs06' where WATERM_STYLE = '6';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs07' where WATERM_STYLE = '7';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs08' where WATERM_STYLE = '8';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs09' where WATERM_STYLE = '9';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs10' where WATERM_STYLE = '10';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs11' where WATERM_STYLE = '11';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs12' where WATERM_STYLE = '12';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs13' where WATERM_STYLE = '13';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs14' where WATERM_STYLE = '14';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs15' where WATERM_STYLE = '15';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs16' where WATERM_STYLE = '16';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs17' where WATERM_STYLE = '17';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs18' where WATERM_STYLE = '18';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs19' where WATERM_STYLE = '19';
UPDATE [jjwater].[dbo].[FH_METERHIS] SET WATERM_STYLE = 'bs20' where WATERM_STYLE = '20';


--########################    FH_CX      #######################################################
truncate table [jjwater].[dbo].FH_CX;

INSERT INTO [jjwater].[dbo].[FH_CX] ([CX_ID], [USERB_KH], [CX_YE], [CX_KHSJ], [USER_ID]) 
SELECT NEWID(),hh,ye,khsj,nuLL FROM jwater.dbo.CX;


UPDATE  [jjwater].[dbo].FH_CX SET CX_YE = t1.CX_YE - T2.JZ FROM [jjwater].[dbo].FH_CX T1,jwater.dbo.JZB T2 WHERE t1.USERB_KH  = T2.KH;

INSERT INTO  [jjwater].[dbo].FH_CX SELECT NEWID(),KH,0-JZ,GETDATE(),NULL FROM jwater.dbo.JZB WHERE JZ <> 0 AND KH NOT IN (SELECT USERB_KH FROM [jjwater].[dbo].FH_CX)

--########################    FH_USERSBANK     #######################################################
truncate table [jjwater].[dbo].[FH_USERSBANK];

INSERT INTO [jjwater].[dbo].[FH_USERSBANK] ([USERSBANK_ID], [USERB_KH], [USERSB_ACCT], [USERSB_NAME], [BANK_NO], [BANK_NAME], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE]) 
SELECT NEWID(),KH,zh, jshm, yhdm, NULL, '1', getdate(), '1', getdate() from jwater.dBO.userbase where len(yhdm) > 0;
UPDATE [jjwater].[dbo].[FH_USERSBANK] SET BANK_NAME = B.BANKNAME FROM jjwater.DBO.FH_USERSBANK A ,jwater.DBO.BANK B WHERE A.BANK_NO = B.BANKID;


--#######################    FH_CASHLIST     #######################################################
truncate table [jjwater].[dbo].[FH_CASHLIST];

INSERT INTO [jjwater].[dbo].[FH_CASHLIST] ([CASHL_ID], [USERB_KH], [USERB_HM], [CASHL_YEAR], [CASHL_MONTH], [CASHL_TOTAL], [CASHL_PAID], [PAID_WAY], [PAID_DATE], [PAID_MOUNT], [PAID_NO], [USER_ID], [LASTM_RETURN], [THISM_RETURN], [RECV_ZNJ], [REBATE_ZNJ], [DEBTL_ZNJ], [CASHL_TAG], [CASHL_NO])
SELECT NEWID(), KH,HM,nf,yf, sfze, sfzje,'9', sfrq, '1', NULL, sfy, syjz, byjz, zljze, jmzlj, zljze-jmzlj,czbz, fphm from jwater.dbo.xjsr;

UPDATE [jjwater].[dbo].[FH_CASHLIST] SET THISM_RETURN = LASTM_RETURN - THISM_RETURN;
UPDATE [jjwater].[dbo].[FH_CASHLIST] SET LASTM_RETURN = 0;


--################################FH_SPECIAL################################
truncate table [jjwater].[dbo].[FH_SPECIAL];

INSERT INTO [jjwater].[dbo].[FH_SPECIAL] ([SP_ID], [USERB_KH], [SP_CONTENT], [OPERATE_PERSON], [OPERATE_DATE], [PRINT_TAG]) 
SELECT NEWID(),kh,Content,oper,CAST(inputdate AS DATETIME),PrintFlag FROM jwater.dbo.UserMemo;
 --------------------------------------------

 --#######################################FH_FGTLIST########
 truncate table [jjwater].[dbo].[FH_FGTLIST];
INSERT INTO [jjwater].[dbo].[FH_FGTLIST] ([FGTLIST_ID], [FGTFLOW_NO], [USERB_KH], [FGT_MKEY], [FGT_YEAR], [FGT_DZDATE], [FGT_STOTAL], [FGT_ATOTAL], [FGT_WYJ], [FGT_LLEFT], [FGT_BLEFT], [FGT_TAG], [FGT_CZTAG], [FGT_SFDATE], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [FGT_WAY], [FGT_MONTH], [USERB_YHDM], [BANK_NUMBER], [CZFLOW_NO], [PAY_DATE], [CZ_REASONS]) 
select  newid(),Lsh,kh,mkey,cast(left(fyrq,4) as int),dzrq,yjje,sjje+wyj,wyj,byys-syys,byys,bz,NULL,cast(convert(varchar(11),sfrq,120)+sfsj as datetime),'1',cast( convert(varchar(11),sfrq,120)+sfsj as datetime),null,null,'2',cast(right(fyrq,2) as int),yhdm,null,null,cast(convert(varchar(11),sfrq,120)+sfsj as datetime),null from jwater.dbo.sfjl;
---------------------------------------------
INSERT INTO [jjwater].[dbo].[FH_FGTLIST] ([FGTLIST_ID], [FGTFLOW_NO], [USERB_KH], [FGT_MKEY], [FGT_YEAR], [FGT_DZDATE], [FGT_STOTAL], [FGT_ATOTAL], [FGT_WYJ], [FGT_LLEFT], [FGT_BLEFT], [FGT_TAG], [FGT_CZTAG], [FGT_SFDATE], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [FGT_WAY], [FGT_MONTH], [USERB_YHDM], [BANK_NUMBER], [CZFLOW_NO], [PAY_DATE], [CZ_REASONS], [CZ_PERSON], [CZ_DATE],[SFY],[SFYNAME]) 
SELECT NEWID(),NULL,KH,mk1,nf,null,sfzje,sfze,0,NULL,null,NULL,czbz,sfrq,'1',getdate(),null,null,'1',yf,yhdm,NULL,NULL,CZRQ,NULL,NULL,NULL,sfy,sfyname FROM jwater.dbo.tssr;

UPDATE jjwater.dbo.FH_FGTLIST SET FGT_CZTAG = '0' WHERE FGT_CZTAG IS NULL;

UPDATE jjwater.dbo.FH_FGTLIST SET FGT_CZTAG = '1' WHERE FGT_TAG = '7';

UPDATE jjwater.dbo.FH_FGTLIST SET USERB_YHDM = left(USERB_YHDM,2),BANK_NUMBER =RIGHT(USERB_YHDM,4) WHERE LEN(USERB_YHDM) = 6;
------################################FH_CXOPHIS###################
truncate table [jjwater].[dbo].[FH_CXOPHIS];
INSERT INTO [jjwater].[dbo].[FH_CXOPHIS] ([CXOPHIS_ID], [USERB_KH], [OPER_DATE], [OPER_WAY], [OPER_MONEY], [CXOP_MONEY], [OPER_USERID], [OPER_KPDATE], [OPER_KPTAG], [OPER_KPH], [OPER_DYDATE], [OPER_HZTAG], [OPER_SFY], [OPER_ZLJZE], [OPER_YSJE], [OPER_YEAR], [OPER_MONTH], [OPER_YQTS], [OPER_ZNJ], [OPER_DESC])
SELECT NEWID(),HH,czsj,czfs,fsje,jy,jbr,kpsj,kpbz,kph,dysj,hzbj,sfy,zljze,sfze,nf,yf,ts,zljze,null from jwater.dbo.cx1;


update [jjwater].[dbo].FH_CXOPHIS set oper_way = '3',oper_desc = left(oper_way,1)+left(right(oper_way,6),4)+'年' +right(oper_way,2) + '月水费' where oper_way like '扣款%';

update [jjwater].[dbo].FH_CXOPHIS set oper_way = '1',oper_desc ='开户存入' where oper_way like '开%';
update [jjwater].[dbo].FH_CXOPHIS set oper_way = '2',oper_desc ='余额存入' where oper_way like '续%';


UPDATE jjwater.dbo.FH_CXOPHIS SET OPER_USERID = T2.USER_ID FROM jjwater.dbo.FH_CXOPHIS T1,jjwater.DBO.SYS_USER T2 WHERE T1.OPER_USERID = T2.NAME;


---############################FH_BILLPRINT ###########################################
----------------本月-----------------------
truncate table [jjwater].[dbo].[FH_BILLPRINT];
INSERT INTO [jjwater].[dbo].[FH_BILLPRINT] ([BILLP_ID], [USERB_KH],[BILLP_YEAR], [BILLP_MONTH],[TRASH_TOTAL], [CHANGE_TOTAL], [BILLP_TYPE],[BILLP_NO], [BILLP_DATE], [BILLP_TAG], [PRINT_TAG], [USER_ID]) 
SELECT NEWID(),RIGHT (t1.ymkhkey, 6) userb_kh,LEFT (t1.ymkhkey, 4) fp_year,RIGHT (LEFT(t1.ymkhkey, 6), 2),0.0,0.0,t1.fptype,t1.fphm,t1.printtime,t1.isnouse,'1',t1.remark from jwater.dbo.dyfpk t1;

UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET userb_hm = t2.hm from [jjwater].[dbo].[FH_BILLPRINT] t1,jwater.dbo.userbase t2 where t1.userb_kh = t2.kh;

UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.WATERUSED T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2016 AND T1.BILLP_MONTH = 6;
UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.w_history2016 T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2016 AND T1.BILLP_MONTH = right(t2.km,2);
UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.w_history2015 T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2015 AND T1.BILLP_MONTH = right(t2.km,2);
UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.w_history2014 T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2014 AND T1.BILLP_MONTH = right(t2.km,2);
UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.w_history2013 T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2013 AND T1.BILLP_MONTH = right(t2.km,2);
UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.w_history2012 T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2012 AND T1.BILLP_MONTH = right(t2.km,2);
UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.w_history2011 T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2011 AND T1.BILLP_MONTH = right(t2.km,2);
UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.w_history2010 T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2010 AND T1.BILLP_MONTH = right(t2.km,2);
UPDATE [jjwater].[dbo].[FH_BILLPRINT] SET USERB_SQDS = T2.SYDS,USERB_BQDS = T2.BYDS,WATERP_QAN = T2.sfsl,WATERU_TOTAL = t2.sf,POLL_TOTAL = T2.pwf,DELAY_TOTAL = T2.ZLJ,PLUS_TOTAL = T2.fjf,MATERIAL_TOTAL = t2.glf,ACTUAL_TOTAL = t2.zje,PAY_TYPE = t2.sfbj FROM [jjwater].[dbo].FH_BILLPRINT T1,jwater.DBO.w_history2009 T2 where t1.userb_kh = t2.kh and t1.BILLP_YEAR = 2009 AND T1.BILLP_MONTH = right(t2.km,2);
UPDATE  [jjwater].[dbo].[FH_BILLPRINT] SET PAY_TYPE = '2' WHERE PAY_TYPE = 'A';
UPDATE  [jjwater].[dbo].[FH_BILLPRINT] SET PAY_TYPE = '2'  WHERE PAY_TYPE = 'B';
UPDATE  [jjwater].[dbo].[FH_BILLPRINT] SET PAY_TYPE = '0' WHERE PAY_TYPE = 'D';
UPDATE  [jjwater].[dbo].[FH_BILLPRINT] SET PAY_TYPE = '1' WHERE PAY_TYPE = 'E';

------################################################FH_DKBANK###############################################################
truncate table jjwater.dbo.fh_dkbank;
 INSERT INTO jjwater.dbo.fh_dkbank([DKB_ID], [USERB_KH], [USERSB_NAME], [USERB_YHDM], [BANK_NAME], [USERSB_ACCT], [DZGS], [SJH], [DZSJ]) 
select newid(),kh,ffhm,dkyh,ffkhh,ffkh,dzgs,sjh,dzsj from  jwater.dbo.DKGXB


--########################################################FH_PAYALT##################################################################################
truncate table [jjwater].[dbo].[FH_PAYALT];
INSERT INTO [jjwater].[dbo].[FH_PAYALT] ([PAYA_ID], [DEBTL_ID], [ALT_TYPE], [ALT_QAN], [ALT_REASON], [CREATE_PERSON], [CREATE_DATE], [VERI_PERSON], [VERI_DATE], [USERB_KH], [USERB_HH], [USERB_HM], [SFY_ID], [AUTH_ID], [AUTH_NAME], [DEBTL_ZNJ], [SF_DATE], [SF_NO], [CZ_TAG], [FH_TAG], [PAY_WAY], [SFY_NAME]) 
   SELECT sn,NULL,'1',jmzlj,NULL,null,getdate(),null,null,kh,hh,hm,sfy,sqr,sqrname,zlj,sfrq,ph,czbz,fhbz,txbj,sfyname from jwater.dbo.jmtab;

UPDATE jjwater.dbo.[FH_PAYALT] SET PAY_WAY = 'sffs01' where PAY_WAY = '1';
UPDATE jjwater.dbo.[FH_PAYALT] SET PAY_WAY = 'sffs04' where PAY_WAY = '4';

--############################################################################################################################################################
--#############################################帐单相关表（FH_DEBTLIST,FH_DEBTOWNHIS,FH_DEBTHIS2016...,FH_PAYLIST,FH_WATERUSED）#############################################
--############################################################################################################################################################
--#######################    FH_JTSS 只在2016年才开始启用     #######################################################
truncate table jjwater.dbo.fh_jtss;
insert into jjwater.dbo.fh_jtss select newid(),kh,2016,cast(right(km,2) as int),sfsl1,sf1,sfsl2,sf2,sfsl3,sf3,sfsl,sf,getdate()  from jwater.dbo.w_history2016 where sfsl1 <> 0;

insert into jjwater.dbo.fh_jtss select newid(),kh,year(getdate()),month(getdate()),sfsl1,sf1,sfsl2,sf2,sfsl3,sf3,sfsl,sf,getdate()  from jwater.dbo.waterused where sfsl1 <> 0;

--#######################    FH_WATERUSED     #######################################################

truncate table [jjwater].[dbo].[FH_WATERUSED];

 INSERT INTO [jjwater].[dbo].[FH_WATERUSED] ([WATERUSED_ID], [VOLUME_NO], [USERB_KH], [USERB_SQDS], [USERB_BQDS], [WATERU_QAN], [EXC_STATUS], [RECORDER], [CAL_STATUS], [CAL_USERID], [THREEMON_AVG], [LAST_QAN], [LASTYEAR_QAN], [EXC_VALUE], [WARN_MIN], [WARN_MAX], [RECORD_STATUS], [USERB_HM], [USERB_YHLX], [CHANGE_QAN], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [IS_CALC], [AREA_NO], [LASTTHREE_FLOAT], [LAST_FLOAT], [LASTYEAR_FLOAT], [CAL_DATE], [WATERU_YEAR], [WATERU_MONTH], [DERATE_QAN], [ADD_QAN], [COUNT_QAN], [WATER_BK], [IS_DONE], [IS_FH], [IS_CBWAY],[RECORD_DATE],[USERB_SFFS])
SELECT NEWID(), null, KH, SYDS, BYDS, BYSY,'0', sfy, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, hbsl, NULL, getdate(), NULL, getdate(),'1', 'A'+sfy, NULL, NULL, NULL, getdate(), YEAR(cbrq), month(cbrq), '0', '0',sfsl,sbqk, '1', '1', '1',cbrq,txbj from jwater.dbo.waterused;
---------------------------------------
 UPDATE [jjwater].[dbo].[FH_waterused] SET VOLUME_NO = B.XH,userb_hm = B.HM FROM [jjwater].[dbo].[FH_WATERUSED] A, jwater.DBO.USERBASE B where A.USERB_KH = B.KH;

UPDATE jjwater.dbo.[FH_WATERUSED] SET USERB_SFFS = 'sffs01' where USERB_SFFS = '1';
UPDATE jjwater.dbo.[FH_WATERUSED] SET USERB_SFFS = 'sffs04' where USERB_SFFS = '4';
UPDATE  [JjWATER].[dbo].[FH_waterused] SET WATER_bk = 'sbbk'+ case when WATER_bk < 10 then '0' + WATER_bk else WATER_bk end;



 --######################    FH_DEBTLIST  ######################################################################
 TRUNCATE TABLE [jjwater].[dbo].FH_DEBTLIST;
 TRUNCATE TABLE [jjwater].[dbo].FH_PAYLIST;
 INSERT INTO [jjwater].[dbo].[FH_DEBTLIST] ([DEBTLIST_ID], [USERB_KH], [DEBTL_YEAR], [DEBTL_MON], [USERB_SQDS], [USERB_BQDS], [WATERU_QAN], [WATERC_QAN], [WATERS_QAN], [WATERQ_QAN], [WATERB_QAN], [WATERP_QAN], [WATERM_STAT], [DEBTL_ZNJ], [DEBTL_ATOTAL], [DEBTL_CPLUS], [IS_PAY], [DEBTL_STOTAL], [CMETER_DATE], [RECORD_DATE], [PAY_TAG], [PAY_DATE], [PAY_WAY], [CHANGE_RATE], [CHANGE_RATETAG], [MONTH_TSPAY], [RECORD_USER], [LAST_TSVIOTOTAL], [IS_EXCPAY], [USERB_YHDM], [BANK_NUMBER], [BANK_TABNO], [BANK_PAYDATE], [BANK_PAYQAN], [BANK_DEALTAG], [BANK_REMARK], [WATERT_NO], [WATER_PRICE], [WATER_EXCPRICE], [METER_CHTAG], [MIXED_USEDTAG], [EST_WATER], [ROLLBACK_TAG], [FREEPULL_TAG], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [DERATE_QAN], [ADD_QAN], [VOLUME_NO], [USERB_HM], [BANK_FLOWNO], [IS_CBWAY])
SELECT NEWID(),kh,year(GETDATE()),month(GETDATE()),syds,byds,bysy,tbsl-jmsl,hbsl,cesl,NULL,sfsl,sbqk,zlj,zje+zlj,null,'1',zje,zhhbrq,cbrq,sfbj,sfrq,NULL,jzbhl,'A'+sfy,dybj,sfy,tbje,txbj,dlyhdm,dlyhsh,dlyhgyh,dlyhsfsj,dlyhsfje,dlyhbz,bz,lb,jj,null,hbbj,hhbj,hhsl,tbbj,jpbz,null,getdate(),null,getdate(),jmsl,tbsl,left(hh,4),NULL,NULL,hhsl from [jwater].[dbo].[waterused];

 ----------------------------------------------------------
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET PAY_TAG = '2',PAY_WAY = '9' WHERE PAY_TAG = 'A' AND IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = 'B';
UPDATE [jjwater].[dbo].[FH_DEBTLIST]SET PAY_TAG = '2',PAY_WAY = '1' WHERE PAY_TAG = 'D' AND IS_EXCPAY = '1';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET PAY_TAG = '2',PAY_WAY = '2' WHERE PAY_TAG = 'D' AND IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET PAY_TAG = '2',PAY_WAY = '2' WHERE PAY_TAG = '9' AND PAY_DATE IS NOT NULL;
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET PAY_TAG = '0',PAY_WAY = null WHERE PAY_TAG = '9' AND PAY_DATE = NULL;
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = 'E';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = '';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG IS NULL;

UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET IS_EXCPAY = 'sffs04' where  IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET IS_EXCPAY = 'sffs01' where  IS_EXCPAY = '1';


UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0101' WHERE WATERT_NO = '1';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0102' WHERE WATERT_NO = '2';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0103' WHERE WATERT_NO = '3';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0201' WHERE WATERT_NO = '4';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0301' WHERE WATERT_NO = '5';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0303' WHERE WATERT_NO = '6';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0304' WHERE WATERT_NO = '7'; 
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0204' WHERE WATERT_NO = '8';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0406' WHERE WATERT_NO = '9';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0401' WHERE WATERT_NO = '10';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0402' WHERE WATERT_NO = '11';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0403' WHERE WATERT_NO = '12';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0404' WHERE WATERT_NO = '13';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0202' WHERE WATERT_NO = '14';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0218' WHERE WATERT_NO = '15';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0305' WHERE WATERT_NO = '16';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0407' WHERE WATERT_NO = '17';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0302' WHERE WATERT_NO = '18';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0405' WHERE WATERT_NO = '19';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0203' WHERE WATERT_NO = '20';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0209' WHERE WATERT_NO = '21';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0214' WHERE WATERT_NO = '22';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0205' WHERE WATERT_NO = '23';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0210' WHERE WATERT_NO = '24';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0215' WHERE WATERT_NO = '25';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0206' WHERE WATERT_NO = '26';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0207' WHERE WATERT_NO = '27';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0211' WHERE WATERT_NO = '28';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0216' WHERE WATERT_NO = '29';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0208' WHERE WATERT_NO = '30';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0212' WHERE WATERT_NO = '31';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0217' WHERE WATERT_NO = '32';
UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET WATERT_NO = '0213' WHERE WATERT_NO = '33';
-----------------------------------------------------------

UPDATE  [JjWATER].[dbo].FH_DEBTLIST SET WATERM_STAT = 'sbbk'+ case when WATERM_STAT < 10 then '0' + WATERM_STAT else WATERM_STAT end;
---------------------------------------------

 UPDATE [jjwater].[dbo].[FH_DEBTLIST] SET USERB_HM = B.HM FROM [jjwater].[dbo].[FH_DEBTLIST] A,[jwater].[dbo].[USERBASE] B where A.userb_kh = B.kh;

INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE])
 SELECT NEWID(), T1.DEBTLIST_ID, '02', '污水处理费', t2.pwf, '1', '1', '1', getdate(), NULL, NULL FROM jjwater.dbo.fh_debtlist t1,jwater.dbo.waterused t2 where t1.userb_kh = t2.kh;
 INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE]) 
 SELECT NEWID(), T1.DEBTLIST_ID, '01', '基本水费', t2.sf, '1', '1', '1', getdate(), NULL, NULL FROM jjwater.dbo.fh_debtlist t1,jwater.dbo.waterused t2 where t1.userb_kh = t2.kh;
 INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE])
 SELECT NEWID(), T1.DEBTLIST_ID, '06', '附加费', t2.fjf, '1', '1', '1', getdate(), NULL, NULL FROM jjwater.dbo.fh_debtlist t1,jwater.dbo.waterused t2 where t1.userb_kh = t2.kh and t2.fjf <> 0;

--#######################    FH_DEBTOWNHIS     #######################################################
TRUNCATE TABLE [jjwater].[dbo].FH_DEBTOWNHIS;
 INSERT INTO [jjwater].[dbo].[FH_DEBTOWNHIS] ([DEBTLIST_ID], [RECORDHIS_DATE], [USERB_KH], [DEBTL_YEAR], [DEBTL_MON], [USERB_SQDS], [USERB_BQDS], [WATERU_QAN], [WATERC_QAN], [WATERS_QAN], [WATERQ_QAN], [WATERB_QAN], [WATERP_QAN], [WATERM_STAT], [DEBTL_ZNJ], [DEBTL_ATOTAL], [DEBTL_CPLUS], [IS_PAY], [DEBTL_STOTAL], [CMETER_DATE], [RECORD_DATE], [PAY_TAG], [PAY_DATE], [PAY_WAY], [CHANGE_RATE], [CHANGE_RATETAG], [MONTH_TSPAY], [RECORD_USER], [LAST_TSVIOTOTAL], [IS_EXCPAY], [USERB_YHDM], [BANK_NUMBER], [BANK_TABNO], [BANK_PAYDATE], [BANK_PAYQAN], [BANK_DEALTAG], [BANK_REMARK], [WATERT_NO], [WATER_PRICE], [WATER_EXCPRICE], [METER_CHTAG], [MIXED_USEDTAG], [EST_WATER], [ROLLBACK_TAG], [FREEPULL_TAG], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [DERATE_QAN], [ADD_QAN], [VOLUME_NO], [USERB_HM], [BANK_FLOWNO], [IS_CBWAY], [BC_TAG]) 
SELECT NEWID(), GETDATE(), KH, YEAR, MONT, syds,qyds, qksl, NULL, null, NULL, NULL, qksl, null,zlj,zje+zlj, null,1, zje, NULL, cast(year as varchar) +'-'+cast(mont as varchar) + '-06', sfbj, hsxzrq,NULL, NULL,'A'+sfy, NULL, sfy, tbje, txbj,NULL, NULL, NULL, NULL, NULL, NULL, NULL,lb,jj, NULL, '0', NULL, hhsl, NULL, jpbz, NULL, getdate(), NULL, getdate(), jmsl, NULL,left(hh,4), NULL, NULL, '1','0' from jwater.dbo.qkhsk;

--########################################################FH_WZB###########################################################################################
TRUNCATE TABLE [jjwater].[dbo].[FH_WZB];
INSERT INTO [jjwater].[dbo].[FH_WZB] ([WZB_ID], [WZB_TYPE], [USERB_KH], [USERB_HM], [USERB_ADDR], [WATERP_QAN], [PRICE], [USERB_STOTAL], [OPER_DATE], [USERB_PWF], [USERB_ATOTAL], [SFY], [BILL_NO], [WASTE_BNO], [USERB_ZNJ])
select id, null,[hh], [hm], [dz], [sl], [dj], [sf], [czsj], [pwf], [zje], [skr], [fphm], [fph], [zlj] from jwater.dbo.wzb

--------------------------------------------

--###################################################################NEW CODE每年都要更新，，1999年到2016年需要导入#####################################################
 truncate table [jjwater].[dbo].[FH_WATERUSEDHIS];
 --#######################################FH_WATERUSEDHIS多个历史表导入#################################


 INSERT INTO [jjwater].[dbo].[FH_WATERUSEDHIS] ([WATERUSEDHIS_ID], [VOLUME_NO], [USERB_KH], [HIS_MONTH], [HIS_YEAR], [USERB_SQDS], [USERB_BQDS], [WATERU_QAN], [EXC_STATUS], [RECORDER], [CAL_STATUS], [CAL_USERID], [THREEMON_AVG], [LAST_QAN], [LASTYEAR_QAN], [EXC_VALUE], [WARN_MIN], [WARN_MAX], [RECORD_STATUS], [USERB_HM], [USERB_YHLX], [CHANGE_QAN], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [IS_CALC], [AREA_NO], [LASTTHREE_FLOAT], [LAST_FLOAT], [LASTYEAR_FLOAT], [SYNC_USERID], [SYNC_DATE], [CAL_DATE], [WATERU_YEAR], [WATERU_MONTH], [DERATE_QAN], [ADD_QAN], [COUNT_QAN], [WATER_BK], [IS_DONE], [IS_FH], [IS_CBWAY],[RECORD_DATE],[USERB_SFFS])
SELECT  NEWID(), left(hh,4), KH,MONTH(cbrq),year(cbrq), SYDS, BYDS, BYSY,'0', sfy, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, hbsl, NULL, getdate(), NULL, getdate(),'1', 'A'+sfy, NULL, NULL, NULL,'1',getdate(), getdate(), YEAR(cbrq), month(cbrq), '0', '0',sfsl, sbqk, '1', '1', '1',cbrq,txbj from jwater.dbo.w_history2010;
-------------------------------


TRUNCATE TABLE [jjwater].[dbo].FH_DEBTHIS2010;
INSERT INTO [jjwater].[dbo].[FH_DEBTHIS2010] ([DEBTLIST_ID], [USERB_KH], [DEBTL_YEAR], [DEBTL_MON], [USERB_SQDS], [USERB_BQDS], [WATERU_QAN], [WATERC_QAN], [WATERS_QAN], [WATERQ_QAN], [WATERB_QAN], [WATERP_QAN], [WATERM_STAT], [DEBTL_ZNJ], [DEBTL_ATOTAL], [DEBTL_CPLUS], [IS_PAY], [DEBTL_STOTAL], [CMETER_DATE], [RECORD_DATE], [PAY_TAG], [PAY_DATE], [PAY_WAY], [CHANGE_RATE], [CHANGE_RATETAG], [MONTH_TSPAY], [RECORD_USER], [LAST_TSVIOTOTAL], [IS_EXCPAY], [USERB_YHDM], [BANK_NUMBER], [BANK_TABNO], [BANK_PAYDATE], [BANK_PAYQAN], [BANK_DEALTAG], [BANK_REMARK], [WATERT_NO], [WATER_PRICE], [WATER_EXCPRICE], [METER_CHTAG], [MIXED_USEDTAG], [EST_WATER], [ROLLBACK_TAG], [FREEPULL_TAG], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [DERATE_QAN], [ADD_QAN], [VOLUME_NO], [USERB_HM], [BANK_FLOWNO], [IS_CBWAY])
SELECT  NEWID(),kh,2010,cast(right(km,2) as int),syds,byds,bysy,tbsl-jmsl,hbsl,cesl,NULL,sfsl,sbqk,zlj,zje+zlj,null,'1',zje,zhhbrq,cbrq,sfbj,sfrq,NULL,jzbhl,'A'+sfy,dybj,sfy,tbje,txbj,dlyhdm,dlyhsh,dlyhgyh,dlyhsfsj,dlyhsfje,dlyhbz,bz,lb,jj,null,hbbj,hhbj,hhsl,tbbj,jpbz,null,getdate(),null,getdate(),jmsl,tbsl,left(hh,4),NULL,NULL,hhsl from [jwater].[dbo].[w_history2010];

--  INSERT INTO [jjwater].[dbo].[FH_DEBTOWNHIS] ([DEBTLIST_ID], [RECORDHIS_DATE], [USERB_KH], [DEBTL_YEAR], [DEBTL_MON], [USERB_SQDS], [USERB_BQDS], [WATERU_QAN], [WATERC_QAN], [WATERS_QAN], [WATERQ_QAN], [WATERB_QAN], [WATERP_QAN], [WATERM_STAT], [DEBTL_ZNJ], [DEBTL_ATOTAL], [DEBTL_CPLUS], [IS_PAY], [DEBTL_STOTAL], [CMETER_DATE], [RECORD_DATE], [PAY_TAG], [PAY_DATE], [PAY_WAY], [CHANGE_RATE], [CHANGE_RATETAG], [MONTH_TSPAY], [RECORD_USER], [LAST_TSVIOTOTAL], [IS_EXCPAY], [USERB_YHDM], [BANK_NUMBER], [BANK_TABNO], [BANK_PAYDATE], [BANK_PAYQAN], [BANK_DEALTAG], [BANK_REMARK], [WATERT_NO], [WATER_PRICE], [WATER_EXCPRICE], [METER_CHTAG], [MIXED_USEDTAG], [EST_WATER], [ROLLBACK_TAG], [FREEPULL_TAG], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [DERATE_QAN], [ADD_QAN], [VOLUME_NO], [USERB_HM], [BANK_FLOWNO], [IS_CBWAY], [BC_TAG]) 
--  SELECT [DEBTLIST_ID],GETDATE(),[USERB_KH], [DEBTL_YEAR], [DEBTL_MON], [USERB_SQDS], [USERB_BQDS], [WATERU_QAN], [WATERC_QAN], [WATERS_QAN], [WATERQ_QAN], [WATERB_QAN], [WATERP_QAN], [WATERM_STAT], [DEBTL_ZNJ], [DEBTL_ATOTAL], [DEBTL_CPLUS], [IS_PAY], [DEBTL_STOTAL], [CMETER_DATE], [RECORD_DATE], [PAY_TAG], [PAY_DATE], [PAY_WAY], [CHANGE_RATE], [CHANGE_RATETAG], [MONTH_TSPAY], [RECORD_USER], [LAST_TSVIOTOTAL], [IS_EXCPAY], [USERB_YHDM], [BANK_NUMBER], [BANK_TABNO], [BANK_PAYDATE], [BANK_PAYQAN], [BANK_DEALTAG], [BANK_REMARK], [WATERT_NO], [WATER_PRICE], [WATER_EXCPRICE], [METER_CHTAG], [MIXED_USEDTAG], [EST_WATER], [ROLLBACK_TAG], [FREEPULL_TAG], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [DERATE_QAN], [ADD_QAN], [VOLUME_NO], [USERB_HM], [BANK_FLOWNO], [IS_CBWAY], [BC_TAG] FROM  [jjwater].[dbo].[FH_DEBTHIS2010] WHERE PAY_TAG = 'B' AND DEBTL_STOTAL <> 0 AND USERB_KH+CAST(DEBTL_YEAR AS VARCHAR)+CAST(DEBTL_MON AS VARCHAR) NOT IN (SELECT USERB_KH+CAST(DEBTL_YEAR AS VARCHAR)+CAST(DEBTL_MON AS VARCHAR) FROM [jjwater].[dbo].FH_DEBTOWNHIS WHERE DEBTL_YEAR = 2010);

DELETE from [jjwater].[dbo].fh_debthis2010 where USERB_KH+CAST(DEBTL_YEAR AS VARCHAR)+CAST(DEBTL_MON AS VARCHAR) IN (SELECT USERB_KH+CAST(DEBTL_YEAR AS VARCHAR)+CAST(DEBTL_MON AS VARCHAR) FROM [jjwater].[dbo].FH_DEBTOWNHIS WHERE DEBTL_YEAR = 2010);

 --------------------------------------
 ----------------------------------------------------------
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '2',PAY_WAY = '9' WHERE PAY_TAG = 'A' AND IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = 'B';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '2',PAY_WAY = '1' WHERE PAY_TAG = 'D' AND IS_EXCPAY = '1';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '2',PAY_WAY = '2' WHERE PAY_TAG = 'D' AND IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '2',PAY_WAY = '2' WHERE PAY_TAG = '9' AND PAY_DATE IS NOT NULL;
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '0',PAY_WAY = null WHERE PAY_TAG = '9' AND PAY_DATE = NULL;
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = 'E';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = '';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG IS NULL;

UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET IS_EXCPAY = 'sffs04' where  IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET IS_EXCPAY = 'sffs01' where  IS_EXCPAY = '1';

UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET USERB_HM = B.HM FROM [jjwater].[dbo].[FH_DEBTHIS2010] A,[jwater].[dbo].[USERBASE] B where A.userb_kh = B.kh;
UPDATE [JjWATER].[dbo].[FH_DEBTHIS2010] SET WATERM_STAT = 'sbbk'+ case when WATERM_STAT < 10 then '0' + WATERM_STAT else WATERM_STAT end;

UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0101' WHERE WATERT_NO = '1';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0102' WHERE WATERT_NO = '2';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0103' WHERE WATERT_NO = '3';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0201' WHERE WATERT_NO = '4';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0301' WHERE WATERT_NO = '5';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0303' WHERE WATERT_NO = '6';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0304' WHERE WATERT_NO = '7'; 
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0204' WHERE WATERT_NO = '8';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0406' WHERE WATERT_NO = '9';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0401' WHERE WATERT_NO = '10';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0402' WHERE WATERT_NO = '11';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0403' WHERE WATERT_NO = '12';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0404' WHERE WATERT_NO = '13';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0202' WHERE WATERT_NO = '14';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0218' WHERE WATERT_NO = '15';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0305' WHERE WATERT_NO = '16';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0407' WHERE WATERT_NO = '17';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0302' WHERE WATERT_NO = '18';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0405' WHERE WATERT_NO = '19';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0203' WHERE WATERT_NO = '20';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0209' WHERE WATERT_NO = '21';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0214' WHERE WATERT_NO = '22';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0205' WHERE WATERT_NO = '23';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0210' WHERE WATERT_NO = '24';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0215' WHERE WATERT_NO = '25';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0206' WHERE WATERT_NO = '26';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0207' WHERE WATERT_NO = '27';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0211' WHERE WATERT_NO = '28';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0216' WHERE WATERT_NO = '29';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0208' WHERE WATERT_NO = '30';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0212' WHERE WATERT_NO = '31';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0217' WHERE WATERT_NO = '32';
UPDATE [jjwater].[dbo].[FH_DEBTHIS2010] SET WATERT_NO = '0213' WHERE WATERT_NO = '33';


----------------------------------来自历史库FH_DEBTHIS2010的PAY_LIST-----------------------------------------------
INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE])
 SELECT NEWID(), T1.DEBTLIST_ID, '02', '污水处理费', t2.pwf, '1', '1', '1', getdate(), NULL, NULL FROM jjwater.dbo.fh_debthis2010 t1,jwater.dbo.w_history2010 t2 where t1.userb_kh = t2.kh and t1.DEBTL_MON = CAST(RIGHT(t2.KM,2) AS INT);
 INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE]) 
 SELECT NEWID(), T1.DEBTLIST_ID, '01', '基本水费', t2.sf, '1', '1', '1', getdate(), NULL, NULL  FROM jjwater.dbo.fh_debthis2010 t1,jwater.dbo.w_history2010 t2 where t1.userb_kh = t2.kh and t1.DEBTL_MON = CAST(RIGHT(t2.KM,2) AS INT);
 INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE])
  SELECT NEWID(), T1.DEBTLIST_ID, '06', '附加费', t2.fjf, '1', '1', '1', getdate(), NULL, NULL FROM jjwater.dbo.fh_debthis2010 t1,jwater.dbo.w_history2010 t2 where t1.userb_kh = t2.kh and t1.DEBTL_MON = CAST(RIGHT(t2.KM,2) AS INT) and t2.fjf <> 0;

-------------------------------------------------FH_FGTLIST 字段更新-----------------------------------------------
UPDATE [jjwater].[dbo].FH_FGTLIST SET WATERP_QAN = B.sfsl,USERB_SFFS = 'sffs0'+cast(B.txbj as varchar) from [jjwater].[dbo].FH_FGTLIST A,jwater.dbo.w_history2010 B where A.USERB_KH = B.KH AND A.FGT_YEAR = 2010 AND A.FGT_MONTH = CAST(RIGHT(B.KM,2) AS INT);

-------------------------------------------------FH_CASHLIST 字段更新-----------------------------------------------
UPDATE [jjwater].[dbo].FH_CASHLIST SET WATERP_QAN = B.sfsl from [jjwater].[dbo].FH_CASHLIST A,jwater.dbo.w_history2010 B where A.USERB_KH = B.KH AND A.CASHL_YEAR = 2010 AND A.CASHL_MONTH = CAST(RIGHT(B.KM,2) AS INT);
UPDATE [jjwater].[dbo].FH_CASHLIST SET DEBTL_ID = B.DEBTLIST_ID from [jjwater].[dbo].FH_CASHLIST A,jjwater.dbo.FH_DEBTHIS2010 B where A.USERB_KH = B.USERB_KH AND A.CASHL_YEAR = B.DEBTL_YEAR AND A.CASHL_MONTH = B.DEBTL_MON;


 -- ###########################################################################################################################
 -- ###########################################################################################################################
  -- ###########################################################################################################################

 ----------------------------------来自FH_DEBTOWNHIS欠费库PAY_LIST-----------------------------------------------
   INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE])
 SELECT NEWID(), T1.DEBTLIST_ID, '02', '污水处理费', t2.pwf, '1', '1', '1', getdate(), NULL, NULL FROM jjwater.dbo.fh_DEBTOWNHIS t1,jwater.dbo.qkhsk t2 where t1.debtl_year = t2.year and t1.userb_kh = t2.kh  AND  t1.DEBTL_MON = t2.mont ;
 INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE]) 
 SELECT NEWID(), T1.DEBTLIST_ID, '01', '基本水费', t2.sf, '1', '1', '1', getdate(), NULL, NULL FROM jjwater.dbo.fh_debtOWNHIS t1,jwater.dbo.qkhsk t2 where  t1.debtl_year = t2.year and t1.userb_kh = t2.kh  AND t1.DEBTL_MON =t2.mont ;
  INSERT INTO [jjwater].[dbo].[FH_PAYLIST] ([PAYL_ID], [DEBTL_ID], [PAYL_NO], [PAYL_NAME], [PAYL_TOTAL], [IS_PAID], [IS_PRINTED], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE]) 
 SELECT NEWID(), T1.DEBTLIST_ID, '06', '附加费', t2.fjf, '1', '1', '1', getdate(), NULL, NULL FROM jjwater.dbo.fh_debtOWNHIS t1,jwater.dbo.qkhsk t2 where t1.debtl_year = t2.year and t1.userb_kh = t2.kh  AND t1.DEBTL_MON =t2.mont and t2.fjf <>0;
 
---------------FH_DEBTOWNHIS 后期处理-------------------------------------
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2009 B WHERE A.DEBTL_YEAR = 2009 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2008 B WHERE A.DEBTL_YEAR = 2008 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2007 B WHERE A.DEBTL_YEAR = 2007 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2006 B WHERE A.DEBTL_YEAR = 2006 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2005 B WHERE A.DEBTL_YEAR = 2005 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2004 B WHERE A.DEBTL_YEAR = 2004 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2003 B WHERE A.DEBTL_YEAR = 2003 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2002 B WHERE A.DEBTL_YEAR = 2002 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2001 B WHERE A.DEBTL_YEAR = 2001 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2000 B WHERE A.DEBTL_YEAR = 2000 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history1999 B WHERE A.DEBTL_YEAR = 1999 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2010 B WHERE A.DEBTL_YEAR = 2010 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2011 B WHERE A.DEBTL_YEAR = 2011 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2012 B WHERE A.DEBTL_YEAR = 2012 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2013 B WHERE A.DEBTL_YEAR = 2013 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2014 B WHERE A.DEBTL_YEAR = 2014 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2015 B WHERE A.DEBTL_YEAR = 2015 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);
UPDATE [jjwater].[dbo].FH_DEBTOWNHIS SET WATERM_STAT = B.sbqk,RECORD_DATE = B.cbrq FROM [jjwater].[dbo].FH_DEBTOWNHIS A ,[jwater].[dbo].w_history2016 B WHERE A.DEBTL_YEAR = 2016 AND A.USERB_KH = B.KH AND A.DEBTL_MON = right(B.km,2);

-------------------------------------------------FH_FGTLIST 字段更新-----------------------------------------------
UPDATE [jjwater].[dbo].FH_FGTLIST SET WATERP_QAN = B.sfsl,USERB_SFFS = 'sffs0'+cast(B.txbj as varchar) from [jjwater].[dbo].FH_FGTLIST A,jwater.dbo.waterused B where A.USERB_KH = B.KH AND A.FGT_YEAR = YEAR(b.cbrq) AND A.FGT_MONTH = month(b.cbrq);

-------------------------------------------------FH_CASHLIST 字段更新-----------------------------------------------
UPDATE [jjwater].[dbo].FH_CASHLIST SET WATERP_QAN = B.sfsl from [jjwater].[dbo].FH_CASHLIST A,jwater.dbo.waterused B where A.USERB_KH = B.KH AND A.CASHL_YEAR = YEAR(b.cbrq) AND A.CASHL_MONTH = month(b.cbrq);
UPDATE [jjwater].[dbo].FH_CASHLIST SET DEBTL_ID = B.DEBTLIST_ID from [jjwater].[dbo].FH_CASHLIST A,jjwater.dbo.FH_DEBTLIST B where A.USERB_KH = B.USERB_KH AND A.CASHL_YEAR = B.DEBTL_YEAR AND A.CASHL_MONTH = B.DEBTL_MON;
UPDATE [jjwater].[dbo].FH_CASHLIST SET DEBTL_ID = B.DEBTLIST_ID from [jjwater].[dbo].FH_CASHLIST A,jjwater.dbo.FH_DEBTOWNHIS B where A.USERB_KH = B.USERB_KH AND A.CASHL_YEAR = B.DEBTL_YEAR AND A.CASHL_MONTH = B.DEBTL_MON;


UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '2',PAY_WAY = '9' WHERE PAY_TAG = 'A' AND IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = 'B';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '2',PAY_WAY = '1' WHERE PAY_TAG = 'D' AND IS_EXCPAY = '1';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '2',PAY_WAY = '2' WHERE PAY_TAG = 'D' AND IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '2',PAY_WAY = '2' WHERE PAY_TAG = '9' AND PAY_DATE IS NOT NULL;
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '0',PAY_WAY = null WHERE PAY_TAG = '9' AND PAY_DATE = NULL;
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = 'E';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG = '';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET PAY_TAG = '0',PAY_WAY = NULL WHERE PAY_TAG IS NULL;

UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET IS_EXCPAY = 'sffs04' where  IS_EXCPAY = '4';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET IS_EXCPAY = 'sffs01' where  IS_EXCPAY = '1';


UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0101' WHERE WATERT_NO = '1';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0102' WHERE WATERT_NO = '2';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0103' WHERE WATERT_NO = '3';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0201' WHERE WATERT_NO = '4';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0301' WHERE WATERT_NO = '5';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0303' WHERE WATERT_NO = '6';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0304' WHERE WATERT_NO = '7'; 
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0204' WHERE WATERT_NO = '8';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0406' WHERE WATERT_NO = '9';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0401' WHERE WATERT_NO = '10';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0402' WHERE WATERT_NO = '11';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0403' WHERE WATERT_NO = '12';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0404' WHERE WATERT_NO = '13';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0202' WHERE WATERT_NO = '14';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0218' WHERE WATERT_NO = '15';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0305' WHERE WATERT_NO = '16';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0407' WHERE WATERT_NO = '17';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0302' WHERE WATERT_NO = '18';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0405' WHERE WATERT_NO = '19';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0203' WHERE WATERT_NO = '20';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0209' WHERE WATERT_NO = '21';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0214' WHERE WATERT_NO = '22';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0205' WHERE WATERT_NO = '23';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0210' WHERE WATERT_NO = '24';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0215' WHERE WATERT_NO = '25';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0206' WHERE WATERT_NO = '26';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0207' WHERE WATERT_NO = '27';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0211' WHERE WATERT_NO = '28';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0216' WHERE WATERT_NO = '29';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0208' WHERE WATERT_NO = '30';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0212' WHERE WATERT_NO = '31';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0217' WHERE WATERT_NO = '32';
UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET WATERT_NO = '0213' WHERE WATERT_NO = '33';
--------------------------------------------------------
 UPDATE [jjwater].[dbo].[FH_DEBTOWNHIS] SET USERB_HM = B.HM FROM [jjwater].[dbo].[FH_DEBTOWNHIS] A,[jwater].[dbo].[USERBASE] B where A.userb_kh = B.kh;
 UPDATE  [JjWATER].[dbo].FH_debtownhis SET WATERM_STAT = 'sbbk'+ case when WATERM_STAT < 10 then '0' + WATERM_STAT else WATERM_STAT end;
 -----------------------------------------------------------------

--------------------------------
UPDATE [jjwater].[dbo].[FH_waterusedhis] SET userb_hm = B.HM FROM [jjwater].[dbo].[FH_WATERUSEDhis] A, jwater.DBO.USERBASE B where A.USERB_KH = B.KH;
UPDATE jjwater.dbo.[FH_WATERUSEDHIS] SET USERB_SFFS = 'sffs01' where USERB_SFFS = '1';
UPDATE jjwater.dbo.[FH_WATERUSEDHIS] SET USERB_SFFS = 'sffs04' where USERB_SFFS = '4';
UPDATE  [JjWATER].[dbo].[FH_waterusedhis] SET WATER_bk = 'sbbk'+ case when WATER_bk < 10 then '0' + WATER_bk else WATER_bk end;

