USE [LYCEUM]
GO
/****** Object:  StoredProcedure [dbo].[Relat_NG_AlunosAbaixoDaMedia]    Script Date: 28/04/2022 16:51:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Relat_NG_AlunosAbaixoDaMedia]
		@faculdade VARCHAR(100),
		@curso VARCHAR(20),
		@ano VARCHAR(20),
		@serie VARCHAR(20),
		@turma VARCHAR(50),
		@bimestre VARCHAR(1),
		@nota_minima DECIMAL(3,1)
/*
DECLARE @faculdade VARCHAR(100),
		@curso VARCHAR(20),
		@ano VARCHAR(20),
		@serie VARCHAR(20),
		@turma VARCHAR(50),
		@bimestre VARCHAR(1),
		@nota_minima DECIMAL(3,1)

SET @faculdade = 'COUTO'
SET @curso = '1004'
SET @ano = '2022'
SET @serie = '3'
SET @turma = '1004-03A'



*/
AS
BEGIN

SELECT n.ANO, n.SEMESTRE, c.FACULDADE, a.CURSO, C.NOME, n.DISCIPLINA, d.NOME_COMPL, a.SERIE,n.TURMA, n.ALUNO, a.NOME_COMPL AS nome_aluno, p.SUBPERIODO, SUBSTRING(n.PROVA,1,CHARINDEX('_',n.PROVA) -1) as PROVA, p.ORDEM, FORMAT(cast(n.CONCEITO AS DECIMAL(3,1)), '0.0') AS CONCEITO
FROM ly_aluno a
 right join LY_NOTA n ON a.aluno = n.aluno
 right join LY_PROVA p ON p.prova = n.prova and p.DISCIPLINA = n.DISCIPLINA and n.turma = p.TURMA and p.ano = n.ano and p.semestre = n.SEMESTRE
 inner join LY_DISCIPLINA d ON d.DISCIPLINA = n.DISCIPLINA and d.DISCIPLINA = p.DISCIPLINA
 inner join LY_CURSO c ON c.curso = a.curso
WHERE n.ano = @ano 
	AND n.semestre = 0
	AND c.FACULDADE = @faculdade
	AND a.curso = @curso 
	AND n.turma = @turma 
	AND a.serie = @serie 
	AND P.SUBPERIODO = @bimestre 
	AND n.PROVA LIKE 'MED%'
	AND n.CONCEITO < @nota_minima
ORDER BY a.NOME_COMPL, a.ALUNO, n.DISCIPLINA
END

