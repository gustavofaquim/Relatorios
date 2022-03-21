USE [LYCEUM]
GO
/****** Object:  StoredProcedure [dbo].[Relat_NG_UnidadeFisica]    Script Date: 21/03/2022 08:51:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[Relat_NG_UnidadeFisica]  
AS  
BEGIN  

	  SELECT NULL AS CODIGO, 'TODOS' AS DESCR
		 UNION
	  SELECT DISTINCT UNIDADE_FIS AS CODIGO, (UNIDADE_FIS + ' - ' + NOME_COMP) FROM LY_UNIDADE_FISICA
	

END  
