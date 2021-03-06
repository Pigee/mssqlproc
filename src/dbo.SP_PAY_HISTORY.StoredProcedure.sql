USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_PAY_HISTORY]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PAY_HISTORY](
		@USERB_KH VARCHAR(36), 
		@BILL_DATE DATE, 
		@BILL_NUM INT,
		@IS_CONTAIN_ARREARS INT
)
AS
BEGIN
	DECLARE @EARLY_YEAR_HIS_TABLE VARCHAR(100),
					@CURR_YEAR_HIS_TABLE VARCHAR(100),
					@CURRENT_YEAR INT,
					@YEARS_AGO INT,
					@STATMENT NVARCHAR(MAX);

	IF @BILL_DATE IS NULL
		SELECT * FROM FH_DEBTLIST WHERE USERB_KH = @USERB_KH;
	ELSE
		BEGIN
			---数量判断
			IF @BILL_NUM > 0
				BEGIN
					IF @BILL_NUM > 12 
						SET @BILL_NUM = 12;

					SET @CURRENT_YEAR = YEAR(GETDATE());
					SET @YEARS_AGO = 1;
					SET @CURR_YEAR_HIS_TABLE = 'FH_DEBTHIS' + CAST(@CURRENT_YEAR AS VARCHAR(4));

					--取历史表名
					WHILE OBJECT_ID(@CURR_YEAR_HIS_TABLE, N'U') IS NULL
						BEGIN
							IF @CURRENT_YEAR < 2000
								BREAK;
							
							SET @CURRENT_YEAR = @CURRENT_YEAR - 1;
							SET @CURR_YEAR_HIS_TABLE = 'FH_DEBTHIS' + + CAST(@CURRENT_YEAR AS VARCHAR(4));
						END

					IF @CURRENT_YEAR < 2000
						BEGIN
							IF @IS_CONTAIN_ARREARS = 1
								SET @STATMENT = 
								'
									SELECT TOP ' + CAST(@BILL_NUM AS VARCHAR(2)) + ' * FROM 
									(
										SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM FH_DEBTLIST WHERE USERB_KH = ''' + @USERB_KH + '''
										UNION ALL
										SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM FH_DEBTOWNHIS WHERE USERB_KH = ''' + @USERB_KH + '''
									) T
								';
						END
					ELSE
						BEGIN
							SET @CURRENT_YEAR = @CURRENT_YEAR - 1;
							SET @EARLY_YEAR_HIS_TABLE = 'FH_DEBTHIS' + CAST(@CURRENT_YEAR AS VARCHAR(4));
							WHILE OBJECT_ID(@EARLY_YEAR_HIS_TABLE, N'U') IS NULL
								BEGIN
									IF @CURRENT_YEAR < 2000
										BREAK;
									SET @CURRENT_YEAR = @CURRENT_YEAR - 1;
									SET @EARLY_YEAR_HIS_TABLE = 'FH_DEBTHIS' + CAST(@CURRENT_YEAR AS VARCHAR(4));
								END
							
							IF @CURRENT_YEAR < 2000
								BEGIN
									IF @IS_CONTAIN_ARREARS = 1
										SET @STATMENT = 
										'
											SELECT TOP ' + CAST(@BILL_NUM AS VARCHAR(2)) + ' * FROM 
											(
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM FH_DEBTLIST WHERE USERB_KH = ''' + @USERB_KH + '''
												UNION ALL
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM FH_DEBTOWNHIS WHERE USERB_KH = ''' + @USERB_KH + '''
												UNION ALL
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM ' + @CURR_YEAR_HIS_TABLE + ' WHERE USERB_KH = ''' + @USERB_KH + '''
											) T
										';
									ELSE
										SET @STATMENT = 
										'
											SELECT TOP ' + CAST(@BILL_NUM AS VARCHAR(2)) + ' DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM ' + @CURR_YEAR_HIS_TABLE + ' WHERE USERB_KH = ''' + @USERB_KH + '''
										';
								END
							ELSE
								BEGIN
									IF @IS_CONTAIN_ARREARS = 1
										SET @STATMENT = 
										'
											SELECT TOP ' + CAST(@BILL_NUM AS VARCHAR(2)) + ' * FROM 
											(
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM FH_DEBTLIST WHERE USERB_KH = ''' + @USERB_KH + '''
												UNION ALL
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM FH_DEBTOWNHIS WHERE USERB_KH = ''' + @USERB_KH + '''
												UNION ALL
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM ' + @CURR_YEAR_HIS_TABLE + ' WHERE USERB_KH = ''' + @USERB_KH + '''
												UNION ALL
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM ' + @EARLY_YEAR_HIS_TABLE + ' WHERE USERB_KH = ''' + @USERB_KH + '''
											) T
										';
									ELSE
										SET @STATMENT = 
										'
											SELECT TOP ' + CAST(@BILL_NUM AS VARCHAR(2)) + ' * FROM 
											(
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM ' + @CURR_YEAR_HIS_TABLE + ' WHERE USERB_KH = ''' + @USERB_KH + '''
												UNION ALL
												SELECT DEBTLIST_ID, USERB_KH, DEBTL_ATOTAL FROM ' + @EARLY_YEAR_HIS_TABLE + ' WHERE USERB_KH = ''' + @USERB_KH + '''
											) T
										';
								END
							EXEC (@STATMENT);
							--PRINT @STATMENT;
						END
				END
		END
	
	
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO
