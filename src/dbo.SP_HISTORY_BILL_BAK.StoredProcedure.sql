USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_HISTORY_BILL_BAK]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 * 功能：根据卡号、年份查找用户账单
 * 
**/
CREATE PROCEDURE [dbo].[SP_HISTORY_BILL_BAK]
(
		@USERB_KH VARCHAR(36), --卡号
		@BILL_YEAR VARCHAR(4), --年份
		@IS_CONTAIN_ARREARS INT --是否包含欠费，0：不包含，其他包含
)
AS
BEGIN
	DECLARE @DEBTHIS_YEAR VARCHAR(MAX), --账单历史表
					@STATEMENT NVARCHAR(MAX),
					@XZ_TYPE VARCHAR(100), --销帐方式
					@BK_TYPE VARCHAR(100); --表况

	SET @XZ_TYPE = 'fh_xzfs';--销帐方式
	SET @BK_TYPE = 'sbbk';
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
										T.USERB_HM,
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
										(T.DEBTL_ATOTAL + T.DEBTL_ZNJ) DEBTL_ATOTAL
										,
										T.WATERS_QAN,
										T.ADD_QAN,
										T.DERATE_QAN,
										T.WATER_PRICE,
										B.DATADIC_NAME WATERM_STAT
					FROM (
						SELECT 	DEBTLIST_ID,
										USERB_KH,
										VOLUME_NO,
										USERB_HM,
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
										DEBTL_ATOTAL
										,
										WATERS_QAN,
										ADD_QAN,
										DERATE_QAN,
										WATER_PRICE,
										WATERM_STAT
						FROM		FH_DEBTLIST 
						WHERE 	DEBTL_YEAR = @BILL_YEAR AND USERB_KH = @USERB_KH
						UNION ALL
						SELECT 	DEBTLIST_ID,
										USERB_KH,
										VOLUME_NO,
										USERB_HM,
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
										END DEBTL_ATOTAL
										,
										WATERS_QAN,
										ADD_QAN,
										DERATE_QAN,
										WATER_PRICE,
										WATERM_STAT
						FROM 		FH_DEBTOWNHIS
						WHERE 	DEBTL_YEAR = @BILL_YEAR AND USERB_KH = @USERB_KH
					) T

					LEFT JOIN FH_DATADIC A
									ON T.PAY_WAY = A.DATADIC_VALUE AND A.DATADIC_TYPE = @XZ_TYPE
					LEFT JOIN FH_DATADIC B
									ON T.WATERM_STAT = A.DATADIC_VALUE AND A.DATADIC_TYPE = @BK_TYPE
					ORDER BY T.DEBTL_YEAR DESC, T.DEBTL_MON DESC
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
											T.VOLUME_NO,
											T.USERB_HM,
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
											(T.DEBTL_ATOTAL + T.DEBTL_ZNJ) DEBTL_ATOTAL
											,
											T.WATERS_QAN,
											T.ADD_QAN,
											T.DERATE_QAN,
											T.WATER_PRICE,
											B.DATADIC_NAME WATERM_STAT
						FROM (
							SELECT 	DEBTLIST_ID,
											USERB_KH,
											VOLUME_NO,
											USERB_HM,
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
											DEBTL_ATOTAL
											,
											WATERS_QAN,
											ADD_QAN,
											DERATE_QAN,
											WATER_PRICE,
											WATERM_STAT
							FROM		FH_DEBTLIST 
							WHERE 	DEBTL_YEAR = ' + @BILL_YEAR + ' AND USERB_KH = ''' + @USERB_KH + '''
							UNION ALL
							SELECT 	DEBTLIST_ID,
											USERB_KH,
											VOLUME_NO,
											USERB_HM,
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
											END DEBTL_ATOTAL
											,
											WATERS_QAN,
											ADD_QAN,
											DERATE_QAN,
											WATER_PRICE,
											WATERM_STAT
							FROM 		FH_DEBTOWNHIS
							WHERE 	DEBTL_YEAR = ' + @BILL_YEAR + ' AND USERB_KH = ''' + @USERB_KH + '''
							UNION ALL
							SELECT 	DEBTLIST_ID,
											USERB_KH,
											VOLUME_NO,
											USERB_HM,
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
											(DEBTL_ATOTAL - DEBTL_ZNJ) DEBTL_ATOTAL
											,
											WATERS_QAN,
											ADD_QAN,
											DERATE_QAN,
											WATER_PRICE,
											WATERM_STAT
							FROM 		' + @DEBTHIS_YEAR + '
							WHERE 	DEBTL_YEAR = ' + @BILL_YEAR + ' AND USERB_KH = ''' + @USERB_KH + '''
						) T

						LEFT JOIN FH_DATADIC A
										ON T.PAY_WAY = A.DATADIC_VALUE AND A.DATADIC_TYPE = ''' + @XZ_TYPE + '''
						LEFT JOIN FH_DATADIC B
										ON T.WATERM_STAT = A.DATADIC_VALUE AND A.DATADIC_TYPE = ''' + @BK_TYPE + '''
						ORDER BY DEBTL_YEAR DESC, DEBTL_MON DESC
					';

				END
			ELSE
				BEGIN
					SET @STATEMENT = 
					'
						SELECT 	T.DEBTLIST_ID,
										T.USERB_KH,
										T.VOLUME_NO,
										T.USERB_HM,
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
										(T.DEBTL_ATOTAL + T.DEBTL_ZNJ) DEBTL_ATOTAL
										,
										T.WATERS_QAN,
										T.ADD_QAN,
										T.DERATE_QAN,
										T.WATER_PRICE,
										B.DATADIC_NAME WATERM_STAT
						FROM 		' + @DEBTHIS_YEAR + ' T

						LEFT JOIN FH_DATADIC A
										ON T.PAY_WAY = A.DATADIC_VALUE AND A.DATADIC_TYPE = ''' + @XZ_TYPE + '''
						LEFT JOIN FH_DATADIC B
										ON T.WATERM_STAT = A.DATADIC_VALUE AND A.DATADIC_TYPE = ''' + @BK_TYPE + '''
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
