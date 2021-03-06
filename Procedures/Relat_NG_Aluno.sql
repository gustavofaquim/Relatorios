USE [LYCEUM]
GO
/****** Object:  StoredProcedure [dbo].[Relat_NG_Aluno]    Script Date: 06/04/2022 15:14:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Relat_NG_Aluno]
(
   --@p_pessoa NUMERIC(10),
   @p_curso VARCHAR(20)
   --@p_ano NUMERIC(4),
   --@p_periodo NUMERIC(2)
)

AS
BEGIN

SELECT DISTINCT a.ALUNO AS CODIGO, 
                ISNULL(a.NOME_ABREV, a.NOME_COMPL) AS NOME_COMPL, 
                (a.ALUNO + ' - ' + ISNULL(a.NOME_ABREV, a.NOME_COMPL)) AS DESCR, 
                a.TIPO_ALUNO 
FROM LY_MATRICULA m  
INNER JOIN VW_ALUNO a ON m.ALUNO = a.ALUNO
WHERE 
	--a.PESSOA = CASE WHEN @p_pessoa IS NULL THEN a.PESSOA ELSE @p_pessoa END AND
      a.CURSO = CASE WHEN @p_curso IS NULL THEN a.CURSO ELSE @p_curso END
      --m.ANO = CASE WHEN @p_ano IS NULL THEN m.ANO ELSE @p_ano END AND
      --m.SEMESTRE = CASE WHEN @p_periodo IS NULL THEN m.SEMESTRE ELSE @p_periodo END
UNION
SELECT DISTINCT a.ALUNO AS CODIGO, 
                a.NOME_COMPL, 
                (a.ALUNO + ' - ' + a.NOME_COMPL) AS DESCR, 
                a.TIPO_ALUNO 
FROM LY_HISTMATRICULA m  
INNER JOIN VW_ALUNO a ON m.ALUNO = a.ALUNO 
WHERE 
	--a.PESSOA = CASE WHEN @p_pessoa IS NULL THEN a.PESSOA ELSE @p_pessoa END AND
      a.CURSO = CASE WHEN @p_curso IS NULL THEN a.CURSO ELSE @p_curso END 
      --m.ANO = CASE WHEN @p_ano IS NULL THEN m.ANO ELSE @p_ano END AND
      --m.SEMESTRE = CASE WHEN @p_periodo IS NULL THEN m.SEMESTRE ELSE @p_periodo END
UNION
SELECT NULL AS CODIGO, 
       NULL AS NOME_COMPL, 
       'TODOS' AS DESCR, 
       NULL AS TIPO_ALUNO
ORDER BY NOME_COMPL

END


