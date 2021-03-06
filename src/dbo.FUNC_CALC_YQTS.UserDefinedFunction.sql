USE [jjwater]
GO
/****** Object:  UserDefinedFunction [dbo].[FUNC_CALC_YQTS]    Script Date: 10/18/2016 15:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	功能：根据给定的年月计算逾期天数
  说明：如果配置了日期，则按改日期算；如果没有，则取当前日期
**/
CREATE FUNCTION [dbo].[FUNC_CALC_YQTS]
( 
	@DEBTL_YEAR INT,
	@DEBTL_MON INT,
	@PAY_BILL_DATE DATE
)
RETURNS INT-- nvarchar
AS
BEGIN
	DECLARE @PEN_TYPE VARCHAR(20), --违约金类型
					@PEN_GRACEDAY INT, --宽限天数
					@PEN_MONTH INT, --间隔月份
					@PAY_DATE INT, --收费日
					@YQTS INT; --逾期天数

--2004.06
	IF @DEBTL_YEAR < 2004 OR (@DEBTL_YEAR = 2004 AND @DEBTL_MON <= 6)
		RETURN 0;

	SELECT  @PEN_TYPE = PEN_TYPE, 
					@PEN_GRACEDAY = PEN_GRACEDAY, 
					@PEN_MONTH = PEN_MONTH, 
					@PAY_DATE = PAY_DATE 	
	FROM 		FH_PENALTY;

	IF @PAY_BILL_DATE IS NULL 
		SET @PAY_BILL_DATE = GETDATE();

	IF @PEN_TYPE = 'wyjff02' --按天收取
		SET @YQTS = DATEDIFF(DAY, 
									DATEADD(MONTH, 
													1, 
													CAST (@DEBTL_YEAR AS VARCHAR) + '-' + 
														CAST ((@DEBTL_MON) AS VARCHAR) + '-' + 
														CAST((case when @PAY_DATE > 0 then @PAY_DATE else 1 END) as VARCHAR)
									), 
									@PAY_BILL_DATE
					) - ISNULL(@PEN_GRACEDAY, 0) + 1;
	ELSE
		SET @YQTS = DATEDIFF(DAY, 
									DATEADD(MONTH, 
													@PEN_MONTH, 
													CAST (@DEBTL_YEAR AS VARCHAR) + '-' + 
														CAST (@DEBTL_MON AS VARCHAR) + '-' +
														CAST((case when @PAY_DATE > 0 then @PAY_DATE else 1 END) AS VARCHAR) 
									) - 1, 
									@PAY_BILL_DATE 
				 );
	
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
	IF @YQTS < 0
		SET @YQTS = 0;

	RETURN @YQTS;
END
GO
