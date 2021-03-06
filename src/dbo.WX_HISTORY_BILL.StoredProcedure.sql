USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_HISTORY_BILL]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * 功能：根据卡号、年份查找用户账单
 * 
**/
CREATE PROCEDURE [dbo].[WX_HISTORY_BILL]
(
		@USERB_KH VARCHAR(36), --卡号
		@BILL_YEAR VARCHAR(4), --年份
		@IS_CONTAIN_ARREARS INT --是否包含欠费，0：不包含欠费，其他包含
)
AS
BEGIN
	DECLARE @DEBTHIS_YEAR VARCHAR(MAX), --账单历史表
					@STATEMENT NVARCHAR(MAX),
					@DATADIC_TYPE VARCHAR(100),
         @SF_TYPE  VARCHAR(20),
					@WSF_TYPE VARCHAR(20),
					@LJF_TYPE VARCHAR(20); 

	SET @DATADIC_TYPE = 'fh_xzfs';--销帐方式
  SET  @SF_TYPE='01';
  SET  @WSF_TYPE='02';
  SET  @LJF_TYPE='03';
	--默认查询本年
	IF @BILL_YEAR IS NULL
		SET @BILL_YEAR = YEAR(GETDATE());

	SET @DEBTHIS_YEAR = 'FH_DEBTHIS' + @BILL_YEAR;

	--历史表不存在，查询所有欠费记录
--------------------------------------------------------------------
	IF OBJECT_ID(@DEBTHIS_YEAR, N'U') IS NULL
		BEGIN
			IF @IS_CONTAIN_ARREARS > 0
				BEGIN
					SELECT 		T.DEBTLIST_ID,
										T.USERB_KH,
										T.VOLUME_NO,
										T.DEBTL_YEAR,
										T.DEBTL_MON,
										CONVERT(VARCHAR(30), T.RECORD_DATE, 23) RECORD_DATE,
                    USERB_SQDS,
										T.USERB_BQDS,
										T.WATERU_QAN,
										T.WATERP_QAN,
										T.PAY_WAY,
										A.DATADIC_NAME PAY_WAY_NAME,
										T.PAY_TAG,
										CONVERT(VARCHAR(30), T.PAY_DATE, 20) PAY_DATE,
										T.DEBTL_ZNJ,
										(T.DEBTL_ATOTAL + T.DEBTL_ZNJ) DEBTL_ATOTAL,
                    (SELECT PAYL_TOTAL FROM FH_PAYLIST PL2 WHERE PL2.DEBTL_ID=DEBTLIST_ID AND PL2.PAYL_NO='02')WSF,
                  (SELECT PAYL_TOTAL FROM FH_PAYLIST PL2 WHERE PL2.DEBTL_ID=DEBTLIST_ID AND PL2.PAYL_NO='01')YSF,
                   (SELECT PAYL_TOTAL FROM FH_PAYLIST PL2 WHERE PL2.DEBTL_ID=DEBTLIST_ID AND PL2.PAYL_NO='03')LJF,
										WATER_PRICE,
                     (Select ust.USERB_HM from FH_USERBASE ust where ust.USERB_KH=@USERB_KH)USERB_HM,
                    (Select ust.USERB_ADDR from FH_USERBASE ust where ust.USERB_KH=@USERB_KH)USERB_ADDR
					FROM (
						SELECT 	DEBTLIST_ID,
										USERB_KH,
										VOLUME_NO,
										DEBTL_YEAR,
										DEBTL_MON,
										RECORD_DATE,
                   USERB_SQDS,
										USERB_BQDS,
										WATERU_QAN,
										WATERP_QAN,
										PAY_WAY,
										PAY_TAG,
										PAY_DATE,
										0 DEBTL_ZNJ,
										DEBTL_ATOTAL,
                    WATER_PRICE
						FROM		FH_DEBTLIST
						WHERE 
DEBTL_YEAR = @BILL_YEAR AND USERB_KH = @USERB_KH
						UNION ALL
						SELECT 	DEBTLIST_ID,
										USERB_KH,
										VOLUME_NO,
										DEBTL_YEAR,
										DEBTL_MON,
										RECORD_DATE,
                    USERB_SQDS,
										USERB_BQDS,
										WATERU_QAN,
										WATERP_QAN,
										PAY_WAY,
										PAY_TAG,
										PAY_DATE,
										CASE WHEN PAY_TAG = 0 THEN
											DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL)
										ELSE
											 DEBTL_ZNJ
										END DEBTL_ZNJ,
										CASE WHEN PAY_TAG = 0 THEN
											DEBTL_ATOTAL
										ELSE 
											DEBTL_ATOTAL - DEBTL_ZNJ
										END DEBTL_ATOTAL,
                      WATER_PRICE
						FROM 		FH_DEBTOWNHIS
						WHERE 	DEBTL_YEAR = @BILL_YEAR AND USERB_KH = @USERB_KH
					) T

					left JOIN FH_DATADIC A
									ON T.PAY_WAY = A.DATADIC_VALUE AND A.DATADIC_TYPE = @DATADIC_TYPE
					ORDER BY T.DEBTL_YEAR ASC, T.DEBTL_MON ASC
				END
		END
--------------------------------------------------------------------------------
	ELSE
		BEGIN
			IF @IS_CONTAIN_ARREARS > 0
				BEGIN
					SET  @STATEMENT = 
					'
						SELECT 		T.DEBTLIST_ID,
											T.USERB_KH,
											T.DEBTL_YEAR,
											T.DEBTL_MON,
											CONVERT(VARCHAR(30), T.RECORD_DATE, 23) RECORD_DATE,
                      T.USERB_SQDS,
											T.USERB_BQDS,
											T.WATERU_QAN,
											T.WATERP_QAN,
											T.PAY_WAY,
											A.DATADIC_NAME PAY_WAY_NAME,
											T.PAY_TAG,
											CONVERT(VARCHAR(30), T.PAY_DATE, 20) PAY_DATE,
											T.DEBTL_ZNJ,
											(T.DEBTL_ATOTAL + T.DEBTL_ZNJ) DEBTL_ATOTAL,
                      (SELECT PAYL_TOTAL FROM FH_PAYLIST PL3 WHERE PL3.DEBTL_ID=DEBTLIST_ID AND PL3.PAYL_NO=' + @WSF_TYPE + ')WSF,
                  (SELECT PAYL_TOTAL FROM FH_PAYLIST PL2 WHERE PL2.DEBTL_ID=DEBTLIST_ID AND PL2.PAYL_NO=' + @SF_TYPE + ')YSF,
                   (SELECT PAYL_TOTAL FROM FH_PAYLIST PL2 WHERE PL2.DEBTL_ID=DEBTLIST_ID AND PL2.PAYL_NO=' + @LJF_TYPE + ')LJF,
										T.WATER_PRICE,
                     (Select ust.USERB_HM from FH_USERBASE ust where ust.USERB_KH='+@USERB_KH+')USERB_HM,
                    (Select ust.USERB_ADDR from FH_USERBASE ust where ust.USERB_KH='+@USERB_KH+')USERB_ADDR
						FROM (
							SELECT 	DEBTLIST_ID,
											USERB_KH,
											DEBTL_YEAR,
											DEBTL_MON,
											RECORD_DATE,
                      USERB_SQDS,
											USERB_BQDS,
											WATERU_QAN,
											WATERP_QAN,
											PAY_WAY,
											PAY_TAG,
											PAY_DATE,
											0 DEBTL_ZNJ,
											DEBTL_ATOTAL,
                      WATER_PRICE
							FROM		FH_DEBTLIST 
							WHERE 	DEBTL_YEAR = ' + @BILL_YEAR + ' AND USERB_KH = ''' + @USERB_KH + '''
							UNION ALL
							SELECT 	DEBTLIST_ID,
											USERB_KH,
											DEBTL_YEAR,
											DEBTL_MON,
											RECORD_DATE,
                      USERB_SQDS,
											USERB_BQDS,
											WATERU_QAN,
											WATERP_QAN,
											PAY_WAY,
											PAY_TAG,
											PAY_DATE,
											CASE WHEN PAY_TAG = 0 THEN
												DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) 
											ELSE
												DEBTL_ZNJ
											END DEBTL_ZNJ,
											CASE WHEN PAY_TAG = 0 THEN
												DEBTL_ATOTAL
											ELSE 
												DEBTL_ATOTAL - DEBTL_ZNJ
											END DEBTL_ATOTAL,
                      WATER_PRICE
							FROM 		FH_DEBTOWNHIS
							WHERE 	DEBTL_YEAR = ' + @BILL_YEAR + ' AND USERB_KH = ''' + @USERB_KH + '''
							UNION ALL
							SELECT 	DEBTLIST_ID,
											USERB_KH,
											DEBTL_YEAR,
											DEBTL_MON,
											RECORD_DATE,
                      USERB_SQDS,
											USERB_BQDS,
											WATERU_QAN,
											WATERP_QAN,
											PAY_WAY,
											PAY_TAG,
											PAY_DATE,
											DEBTL_ZNJ,
											(DEBTL_ATOTAL - DEBTL_ZNJ) DEBTL_ATOTAL,
                      WATER_PRICE
							FROM 		' + @DEBTHIS_YEAR + '
							WHERE 	DEBTL_YEAR = ' + @BILL_YEAR + ' AND USERB_KH = ''' + @USERB_KH + '''
						) T

						left JOIN FH_DATADIC A
										ON T.PAY_WAY = A.DATADIC_VALUE AND A.DATADIC_TYPE = ''' + @DATADIC_TYPE + '''

						ORDER BY DEBTL_YEAR ASC, DEBTL_MON ASC
					';

				END
			ELSE
				BEGIN
					SET @STATEMENT = 
					'
						SELECT 	T.DEBTLIST_ID,
										T.USERB_KH,
										T.DEBTL_YEAR,
										T.DEBTL_MON,
										CONVERT(VARCHAR(30), T.RECORD_DATE, 23) RECORD_DATE,
                    USERB_SQDS,
										T.USERB_BQDS,
										T.WATERU_QAN,
										T.WATERP_QAN,
										T.PAY_WAY,
										A.DATADIC_NAME PAY_WAY_NAME,
										T.PAY_TAG,
										CONVERT(VARCHAR(30), T.PAY_DATE, 20) PAY_DATE,
										T.DEBTL_ZNJ,
										(T.DEBTL_ATOTAL + T.DEBTL_ZNJ) DEBTL_ATOTAL
						FROM 		' + @DEBTHIS_YEAR + ' T

						left JOIN FH_DATADIC A
										ON T.PAY_WAY = A.DATADIC_VALUE AND A.DATADIC_TYPE = ''' + @DATADIC_TYPE + '''

						WHERE 	DEBTL_YEAR = ' + @BILL_YEAR + ' AND USERB_KH = ''' + @USERB_KH + '''
						ORDER BY DEBTL_YEAR DESC, DEBTL_MON DESC
					';

				END
			EXEC (@STATEMENT);
		END
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO
