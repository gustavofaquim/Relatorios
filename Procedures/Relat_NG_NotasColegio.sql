USE [LYCEUM]
GO
/****** Object:  StoredProcedure [dbo].[Relat_NG_NotasColegio]    Script Date: 28/04/2022 16:50:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Relat_NG_NotasColegio]
		@faculdade VARCHAR(100),
		@curso VARCHAR(20),
		@ano VARCHAR(20),
		@serie VARCHAR(20),
		@turma VARCHAR(50),
		@bimestre VARCHAR(20),
		@disciplina VARCHAR(50),
		@nota_minima DECIMAL(3,1)

AS
BEGIN

SELECT n.ANO, n.SEMESTRE, c.FACULDADE, a.CURSO, C.NOME, n.DISCIPLINA, d.NOME_COMPL, a.SERIE,n.TURMA, n.ALUNO, a.NOME_COMPL AS nome_aluno,p.SUBPERIODO, SUBSTRING(n.PROVA,1,CHARINDEX('_',n.PROVA) -1) as PROVA, p.ORDEM, FORMAT(cast(n.CONCEITO AS DECIMAL(3,1)), '#.0') AS CONCEITO
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
	AND (@disciplina IS NULL OR (@disciplina  IS NOT NULL AND(n.disciplina = @disciplina)))
	AND EXISTS(SELECT CONCEITO FROM LY_NOTA n2 WHERE n2.ALUNO = n.ALUNO and n2.ANO = n.ano AND n2.SEMESTRE = n.SEMESTRE AND n2.DISCIPLINA = n.DISCIPLINA AND n2.TURMA = n.TURMA AND n2.PROVA LIKE 'MED%' AND /* n2.CONCEITO < @nota_minima */ (@nota_minima IS NULL OR (@nota_minima  IS NOT NULL AND(n2.CONCEITO < @nota_minima))))
GROUP BY n.ano, n.semestre, c.FACULDADE, a.curso, C.NOME, n.disciplina, d.NOME_COMPL, a.serie,n.turma, n.aluno, a.nome_compl, p.SUBPERIODO, n.prova, p.ORDEM,n.conceito
ORDER BY n.ano, n.semestre, c.FACULDADE, a.curso, C.NOME, n.disciplina, d.NOME_COMPL, a.serie,n.turma, n.aluno, a.nome_compl, p.SUBPERIODO, n.prova, p.ORDEM,n.conceito

END

