USE [LYCEUM]
GO
/****** Object:  StoredProcedure [dbo].[Relat_NG_Total_Servicos]    Script Date: 06/04/2022 15:00:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--EXEC [PR_TOTAL_SERVICOS] 2019, ''

ALTER PROCEDURE [dbo].[Relat_NG_Total_Servicos] 
	@ano VARCHAR(4),
    @unidade VARCHAR(20)
	--@curso  VARCHAR(20)
	
AS 
--IF @ano = '' 
--set @ano = null
--IF @unidade = '' 
--set @unidade = null

 BEGIN
SELECT SERVICO,
       DESCRICAO,
       Mes,
       Ano,
       Unidade,
       count(SERVICO) qtd
FROM
  (SELECT S.SERVICO,
          t.DESCRICAO,
          month(ss.DATA) AS Mes,
          YEAR(SS.DATA) AS Ano,
          c.faculdade AS Unidade
   FROM Ly_Itens_Solicit_Serv S
   INNER JOIN Ly_Solicitacao_Serv SS ON ss.SOLICITACAO=s.SOLICITACAO
   INNER JOIN LY_ALUNO a ON ss.ALUNO=a.ALUNO
   INNER JOIN LY_TABELA_SERVICOS t ON s.SERVICO = t.SERVICO
   INNER JOIN ly_curso c ON c.curso = a.curso
   WHERE S.SERVICO LIKE '%AOL201%-%'
     AND (@unidade IS NULL OR (@unidade IS NOT NULL AND(c.faculdade = @unidade)))
	-- AND (@curso IS NULL OR (@curso IS NOT NULL AND(c.CURSO = @curso)))
     AND YEAR(SS.DATA) = @ano ) AS aux
GROUP BY SERVICO,
         DESCRICAO,
         Unidade,
         Mes,
         Ano
ORDER BY 2,
         3 END

