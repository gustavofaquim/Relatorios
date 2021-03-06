USE [LYCEUM]
GO
/****** Object:  StoredProcedure [dbo].[Relat_NG_HistoricoEscolar2]    Script Date: 06/04/2022 15:14:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--EXEC Relat_HistoricoEscolar NULL, NULL, NULL, NULL, NULL,'1620583', NULL, NULL, NULL

ALTER PROCEDURE [dbo].[Relat_NG_HistoricoEscolar2]
(
    @p_unidade AS T_CODIGO,
    @p_tipo AS T_CODIGO,
    @p_curso AS T_CODIGO,
    --@p_ano AS T_ANO,
    --@p_periodo AS T_SEMESTRE2,
    @p_aluno AS T_CODIGO,
    --@p_pessoa AS T_CODIGO,
    --@p_indice_semestral AS VARCHAR(20),
    --@p_indice_media_geral AS VARCHAR(20),
	@usuario VARCHAR(15)
)
AS
BEGIN

if @usuario is not null
	exec Relat_RestricaoAcesso_SemRetorno @usuario

if @p_aluno is not null -- adicionado Gustavo
	EXEC RELAT_NG_HISTORICO_AUX_EQUIVALENCIA @p_aluno  -- atualiza a lista de disciplinas equivalentes do aluno

DECLARE @MAX_ANO AS VARCHAR(4)
DECLARE @MAX_PERIODO AS VARCHAR(2)

SET @MAX_ANO = CAST((SELECT TOP 1 ANO FROM LY_HISTMATRICULA WHERE ALUNO = @p_aluno ORDER BY ANO DESC, SEMESTRE DESC) AS VARCHAR(4))
SET @MAX_PERIODO = CAST((SELECT TOP 1 SEMESTRE FROM LY_HISTMATRICULA WHERE ALUNO = @p_aluno ORDER BY ANO DESC, SEMESTRE DESC) AS VARCHAR(2))

DECLARE @matricula AS VARCHAR(20)
DECLARE @codigo AS NUMERIC(10)
DECLARE @campo_ordenacao AS VARCHAR(6)
DECLARE @total_creditos AS NUMERIC(5,2)
DECLARE @total_media_final AS NUMERIC(5,2)
DECLARE @resultado AS NUMERIC(5,2)
    SET @total_creditos = 0
    SET @total_media_final = 0
    SET @resultado = 0
DECLARE @p_indice_semestral AS VARCHAR(20)
	SET @p_indice_semestral = '0'
DECLARE @p_indice_media_geral AS VARCHAR(20)
	SET @p_indice_media_geral = '0'

  -- CRIAÇÃO DA TABELA TEMPORÁRIA
 CREATE TABLE #HISTOFICIAL (
	  NOME_ALUNO VARCHAR(100) COLLATE Latin1_General_CI_AI NOT NULL,
	  MATRICULA VARCHAR(20) COLLATE Latin1_General_CI_AI NOT NULL,
	  NOME_CURSO VARCHAR(100) COLLATE Latin1_General_CI_AI NOT NULL, -- adicionado Gustavo
	  HABILITACAO VARCHAR(100) COLLATE Latin1_General_CI_AI NOT NULL, -- adicionado Gustavo
	  DECRETO VARCHAR(100) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
      INEP_CURSO VARCHAR(20) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  CURSO VARCHAR(9) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  TITULO VARCHAR(150) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  INEP_DOC VARCHAR(450) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  CODIGO NUMERIC(10),
	  TURNO VARCHAR(100) COLLATE Latin1_General_CI_AI,
      NACIONALIDADE VARCHAR(15) COLLATE Latin1_General_CI_AI,
      NATURAL_ESTADO VARCHAR(50) COLLATE Latin1_General_CI_AI,
      DATA_NASCIMENTO DATETIME,
      DOCUMENTO VARCHAR(50) COLLATE Latin1_General_CI_AI,
	  ESTABELECIMENTO_2G VARCHAR(100) COLLATE Latin1_General_CI_AI,
	  LOCAL_2G VARCHAR(50) COLLATE Latin1_General_CI_AI,
	  ANOCONCL_2G NUMERIC(04),
      DATA_VESTIBULAR DATETIME,
      TIPO_INGRESSO VARCHAR(200) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  ANO_INGRESSO VARCHAR(200) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  CURRICULO VARCHAR(200) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  CLASSIFICACAO_VEST NUMERIC(10),
	  NOME_FACULDADE_VEST VARCHAR(100) COLLATE Latin1_General_CI_AI,
	  FACULDADE VARCHAR(100) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  INEP_FACULDADE VARCHAR(450) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  PROVAVEST VARCHAR(20) COLLATE Latin1_General_CI_AI,
	  NOTA_PADRONIZADA VARCHAR(15) COLLATE Latin1_General_CI_AI,
      CAMPO_ORDENACAO VARCHAR(6) COLLATE Latin1_General_CI_AI,
      COD_DISC VARCHAR(20) COLLATE Latin1_General_CI_AI,
      NOME_DISC VARCHAR(200) COLLATE Latin1_General_CI_AI,
      --DICIPLINAS_PENDENTES  VARCHAR(200) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  NOME_DOCENTE VARCHAR(200) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  TITULACAO VARCHAR(50) COLLATE Latin1_General_CI_AI, -- adicionado Gustavo
	  PERIODO_LETIVO VARCHAR(6) COLLATE Latin1_General_CI_AI,
      SEMESTRE_ALUNO NUMERIC(3),
	  SERIE_IDEAL NUMERIC(3),
      CREDITOS DECIMAL(10,2),
      HORAS_AULA DECIMAL(10,2), -- adicionado Gustavo
	  HORAS_LAB DECIMAL(10,2), -- adicionado Gustavo
	  HORAS_ATIV DECIMAL(10,2), -- adicionado Gustavo
	  CARGA_HORARIA DECIMAL(10,2),
	  MEDIA_FINAL NUMERIC(5,2),
      MEDIA_FINAL_HM VARCHAR(15) COLLATE Latin1_General_CI_AI,
      OBSERVACOES VARCHAR(20) COLLATE Latin1_General_CI_AI,
	  CH_CUMPRIDA DECIMAL(10,2),  -- adicionado Gustavo
      MEDIA_SEMESTRAL NUMERIC(5,2),
      MEDIA_GERAL_CURSO NUMERIC(5,2),
      OBS_HISTORICO VARCHAR(5000) COLLATE Latin1_General_CI_AI,
      COLACAO_GRAU DATETIME,
      EXPD_DIPLOMA DATETIME,
	  DT_CONCLUSAO DATETIME,
	  DT_ENEM VARCHAR(7) COLLATE Latin1_General_CI_AI,
      CARGA_HORARIA_ESTAGIO VARCHAR(50) COLLATE Latin1_General_CI_AI,
      ESTAGIO_SN CHAR(1),
	  NOME_PAI VARCHAR(100) COLLATE Latin1_General_CI_AI,
	  NOME_MAE VARCHAR(100) COLLATE Latin1_General_CI_AI,
	  RG_NUM VARCHAR(20) COLLATE Latin1_General_CI_AI,
	  RG_EMISSOR VARCHAR(15) COLLATE Latin1_General_CI_AI,
	  UF_SIGLA VARCHAR(15) COLLATE Latin1_General_CI_AI,
	  CPF VARCHAR(20) COLLATE Latin1_General_CI_AI, -- incluido Gustavo
	  ALIST_NUM VARCHAR(17) COLLATE Latin1_General_CI_AI,
	  ALIST_RM VARCHAR(15) COLLATE Latin1_General_CI_AI,
	  ALIST_SERIE VARCHAR(15) COLLATE Latin1_General_CI_AI,
	  DT_NASC DATETIME,
	  MUNICIPIO_UNIDADE VARCHAR(200) COLLATE Latin1_General_CI_AI,
	  MUNICIPIO_NASC VARCHAR(50) COLLATE Latin1_General_CI_AI,
	  TELEITOR_NUM VARCHAR(15) COLLATE Latin1_General_CI_AI,
	  TELEITOR_ZONA VARCHAR(15) COLLATE Latin1_General_CI_AI,
	  TELEITOR_SECAO VARCHAR(15) COLLATE Latin1_General_CI_AI
)

            INSERT INTO #HISTOFICIAL
            SELECT ISNULL(a.NOME_SOCIAL, a.NOME_COMPL) AS NOME_ALUNO,
                   m.ALUNO AS MATRICULA,
				   c.NOME, -- adicionado Gustavo
				   c.HABILITACAO, -- adicionado Gustavo
				   c.DECRETO, -- adicionado Gustavo
				   c.INEP_CURSO, -- adicionado Gustavo
				   c.CURSO,-- adicionado Gustavo
				   c.TITULO, -- adicionado Gustavo
				   (CASE WHEN INEP_TIPODOC_REC IS NULL THEN ('Curso criado pela ' + INEP_TIPODOC_CRIACAO  + ', de ' + CONVERT(VARCHAR, INEP_DTDESPACHO_CRIACAO, 103)) ELSE
				   (CASE WHEN INEP_TIPODOC_REC IS NOT NULL AND INEP_TIPODOC_RENOV IS NOT NULL  THEN ('Curso reconhecido pelo ' + INEP_TIPODOC_REC + ' nº ' + INEP_NUMDOC_REC + ', de ' + CONVERT(VARCHAR, INEP_DTPUBL_REC, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTDESPACHO_REC, 103) + ' renovado o reconhecimento pela ' + INEP_TIPODOC_RENOV + ' nº ' + INEP_NUMDOC_RENOV + ', de ' + CONVERT(VARCHAR,INEP_DTDESPACHO_RENOV, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTPUBL_RENOV, 103)) ELSE
				   (CASE WHEN INEP_TIPODOC_REC IS NOT NULL THEN ('Curso reconhecido pelo ' + INEP_TIPODOC_REC + ' nº ' + INEP_NUMDOC_REC + ', de ' + CONVERT(VARCHAR, INEP_DTPUBL_REC, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTDESPACHO_REC, 103)) END)
				   END) END) AS INEP_DOC, -- adicionado Gustavo
                   a.PESSOA AS CODIGO,
				   '' AS TURNO, -- t.DESCRICAO AS TURNO,
                   p.NACIONALIDADE AS NACIONALIDADE,
                   (SELECT NOME FROM dbo.MUNICIPIO WHERE CODIGO = p.MUNICIPIO_NASC) AS NATURAL_ESTADO,
                   p.DT_NASC AS DATA_NASCIMENTO,
                   (CASE
                        WHEN p.NACIONALIDADE = 'BRASILEIRA' THEN ('RG - ' + p.RG_NUM + Space(5) + p.RG_EMISSOR) 
                        ELSE (CASE 
                                  WHEN p.RG_TIPO = 'RNE' THEN ('RNE - ' + p.RG_NUM) 
                                  ELSE ('PASSAPORTE - ' + p.PASSAPORTE)
                              END)
                   END) AS DOCUMENTO,
				   a.OUTRA_FACULDADE AS ESTABELECIMENTO_2G,
				   '' AS LOCAL_2G,--mn.NOME AS LOCAL_2G,
				   a.ANOCONCL_2G,
                   vest.DTVEST AS DATA_VESTIBULAR,
				   a.TIPO_INGRESSO, -- adicionado Gustavo
				   a.ANO_INGRESSO, -- adicionado Gustavo
				   a.CURRICULO, -- adicionado Gustavo
                   vest.CLASSIFICACAO AS CLASSIFICACAO_VEST,
				   --ISNULL(f1.NOME_COMP, f2.NOME_COMP) AS NOME_FACULDADE_VEST,
				   f1.NOME_COMP AS NOME_FACULDADE_VEST,
				   f1.FACULDADE,  -- adicionado Gustavo
				   '' AS DESCR, -- adicionado Gustavo
				   '' AS PROVAVEST,
				   '' AS NOTA_PADRONIZADA,
                   /*CASE
                       WHEN m.ANO > a.ANO_INGRESSO THEN CAST(m.SEMESTRE AS VARCHAR(2)) + '/' + CAST(m.ANO AS VARCHAR(4))
                       WHEN m.ANO < a.ANO_INGRESSO THEN CAST(a.SEM_INGRESSO AS VARCHAR(2)) + '/' + CAST(a.ANO_INGRESSO AS VARCHAR(4))
                       WHEN m.ANO = a.ANO_INGRESSO THEN
                            CASE WHEN m.SEMESTRE >= a.SEM_INGRESSO THEN CAST(m.SEMESTRE AS VARCHAR(2)) + '/' + CAST(m.ANO AS VARCHAR(4))
                            ELSE CAST(a.SEM_INGRESSO AS VARCHAR(2)) + '/' + CAST(m.ANO AS VARCHAR(4))
                            END
                   END AS CAMPO_ORDENACAO,*/ CAST(m.SEMESTRE AS VARCHAR(1)) + '/' + CAST(m.ANO AS VARCHAR(4)) AS CAMPO_ORDENACAO,
                   m.DISCIPLINA AS COD_DISC,
                   d.NOME_COMPL AS NOME_DISC,
				   do.NOME_COMPL AS NOME_COMPL, -- adicionado Gustavo
				   CASE
                       WHEN UPPER(do.TITULACAO) = 'MESTRADO COMPLETO' THEN 'MESTRE'
					   WHEN UPPER(do.TITULACAO) = 'MESTRADO' THEN 'MESTRE'
                       WHEN UPPER(do.TITULACAO) = 'MESTRADO INCOMPLETO' THEN 'MESTRE'
					   WHEN UPPER(do.TITULACAO) = 'ESPECIALIZACAO'  THEN 'ESPECIALISTA'
					   WHEN UPPER(do.TITULACAO) = 'PÓS GRAD. COMPLETO'  THEN 'ESPECIALISTA'
					   WHEN UPPER(do.TITULACAO) = 'DOUTORADO COMPLETO' THEN 'DOUTOR'
					   WHEN UPPER(do.TITULACAO) = 'DOUTORADO' THEN 'DOUTOR'
					   WHEN UPPER(do.TITULACAO) = 'DOUTORADO INCOMPLETO' THEN 'DOUTOR'
					   WHEN UPPER(do.TITULACAO) = 'SUPERIOR COMPLETO' THEN 'GRADUADO'
					   WHEN UPPER(do.TITULACAO) = 'SUPERIOR' THEN 'GRADUADO'
					   ELSE UPPER(do.TITULACAO)
				   END,
                   --CAST (m.SEMESTRE AS VARCHAR(2)) + '/' + CAST (m.ANO AS VARCHAR(4)) AS PERIODO_LETIVO,
                   CAST (m.ANO AS VARCHAR(4)) + '.' + CAST (m.SEMESTRE AS VARCHAR(1)) AS PERIODO_LETIVO,
                   a.SERIE AS SEMESTRE_ALUNO,
				   0 AS SERIE_IDEAL,
                   d.CREDITOS AS CREDITOS,
				   --d.HORAS_AULA AS CARGA_HORARIA,
				   d.HORAS_AULA, -- adicionado Gustavo
				   d.HORAS_LAB, -- adicionado Gustavo
				   d.HORAS_ATIV, -- adicionado Gustavo
				    (
					SELECT SUM(d1.HORAS_AULA + d1.HORAS_LAB + d1.HORAS_ATIV) FROM LY_DISCIPLINA d1 -- HORAS_AULA + HORAS_LAB + HORAS_ATIV
					WHERE d1.DISCIPLINA = d.DISCIPLINA
				   ) AS CARGA_HORARIA,
                   0 AS MEDIA_FINAL,
                   0 AS MEDIA_FINAL_HM,
                   m.SIT_MATRICULA AS OBSERVACOES,
				   0 AS CH_CUMPRIDA,
                   NULL AS MEDIA_SEMESTRAL,
                   NULL AS MEDIA_GERAL_CURSO,
                   dbo.fnRelatHistMatricObsExtra(a.ALUNO) AS OBS_HISTORICO,
                   cconcl.DT_COLACAO AS COLACAO_GRAU,
                   cconcl.DT_DIPLOMA AS EXPD_DIPLOMA,
				   cconcl.DT_ENCERRAMENTO AS DT_CONCLUSAO,
				   NULL AS DT_ENEM,
                   CAST(dbo.fnRelatGetHoras (a.ALUNO, 'CH') AS VARCHAR(6)) + ' + ' + CAST(dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO') AS VARCHAR(6)) + ' (ESTÁGIO) = ' + CAST ((dbo.fnRelatGetHoras (a.ALUNO, 'CH') + dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO')) AS VARCHAR(6)) AS CARGA_HORARIA_ESTAGIO,
                   CASE WHEN dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO') > 0 THEN 'S' ELSE 'N' END AS ESTAGIO_SN,
				   p.NOME_PAI,
				   p.NOME_MAE,
				   p.RG_NUM,
				   p.RG_EMISSOR,
				   p.RG_UF,
				   p.CPF, -- incluido Gustavo
				   p.ALIST_NUM,
				   p.ALIST_RM,
				   p.ALIST_SERIE,
				   p.DT_NASC,
				   '' AS MUNICIPIO_UNIDADE,
				   '' AS MUNICIPIO_NASC,
				   p.TELEITOR_NUM,
				   p.TELEITOR_ZONA,
				   p.TELEITOR_SECAO
            FROM LY_MATRICULA m INNER JOIN
                 VW_ALUNO a ON m.ALUNO = a.ALUNO INNER JOIN
                 LY_DISCIPLINA d ON m.DISCIPLINA = d.DISCIPLINA INNER JOIN
                 LY_TURMA hd ON d.DISCIPLINA = hd.DISCIPLINA AND hd.ANO = m.ANO AND hd.SEMESTRE = m.SEMESTRE INNER JOIN  -- adicionado Gustavo
				 LY_DOCENTE do ON hd.NUM_FUNC = do.NUM_FUNC INNER JOIN -- adicionado Gustavo
				 VW_CURSO c ON a.CURSO = c.CURSO LEFT JOIN
                 LY_H_CURSOS_CONCL cconcl ON a.ALUNO = cconcl.ALUNO AND a.CURSO = cconcl.CURSO AND a.TURNO = cconcl.TURNO AND a.CURRICULO = cconcl.CURRICULO LEFT JOIN
                 LY_PESSOA p ON a.PESSOA = p.PESSOA LEFT JOIN
                 LY_DADOS_VESTIBULAR vest ON a.ALUNO = vest.ALUNO LEFT JOIN
				 LY_FACULDADE f1 ON vest.OUTRA_FACULDADE = f1.FACULDADE LEFT JOIN
				  ITEMTABELA it ON f1.FACULDADE = it.item  -- adicionado Gustavo
            WHERE c.FACULDADE =  CASE WHEN @p_unidade IS NULL THEN c.FACULDADE ELSE @p_unidade END AND
                  c.TIPO = CASE WHEN @p_tipo IS NULL THEN c.TIPO ELSE @p_tipo END AND
                  a.CURSO = CASE WHEN @p_curso IS NULL THEN a.CURSO ELSE @p_curso END AND 
                  --a.ANO_INGRESSO = CASE WHEN @p_ano IS NULL THEN a.ANO_INGRESSO ELSE @p_ano END AND
                  --a.SEM_INGRESSO = CASE WHEN @p_periodo IS NULL THEN a.SEM_INGRESSO ELSE @p_periodo END AND
                  a.ALUNO = CASE WHEN @p_aluno IS NULL THEN a.ALUNO ELSE @p_aluno END AND
                 -- a.PESSOA = CASE WHEN @p_pessoa IS NULL THEN a.PESSOA ELSE @p_pessoa END AND
                  d.ESTAGIO = 'N'
            
            UNION
            
            SELECT ISNULL(a.NOME_SOCIAL, a.NOME_COMPL) AS NOME_ALUNO,
                    m.ALUNO AS MATRICULA,
				   c.NOME, -- adicionado Gustavo
				   c.HABILITACAO, -- adicionado Gustavo
				   c.DECRETO,  -- adicionado Gustavo
                   c.INEP_CURSO, -- adicionado Gustavo
				   c.CURSO,-- adicionado Gustavo
				   c.TITULO, -- adicionado Gustavo
				   (CASE WHEN INEP_TIPODOC_REC IS NULL THEN ('Curso criado pela ' + INEP_TIPODOC_CRIACAO  + ', de ' + CONVERT(VARCHAR, INEP_DTDESPACHO_CRIACAO, 103)) ELSE
				   (CASE WHEN INEP_TIPODOC_REC IS NOT NULL AND INEP_TIPODOC_RENOV IS NOT NULL  THEN ('Curso reconhecido pelo ' + INEP_TIPODOC_REC + ' nº ' + INEP_NUMDOC_REC + ', de ' + CONVERT(VARCHAR, INEP_DTPUBL_REC, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTDESPACHO_REC, 103) + ' renovado o reconhecimento pela ' + INEP_TIPODOC_RENOV + ' nº ' + INEP_NUMDOC_RENOV + ', de ' + CONVERT(VARCHAR,INEP_DTDESPACHO_RENOV, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTPUBL_RENOV, 103)) ELSE
				   (CASE WHEN INEP_TIPODOC_REC IS NOT NULL THEN ('Curso reconhecido pelo ' + INEP_TIPODOC_REC + ' nº ' + INEP_NUMDOC_REC + ', de ' + CONVERT(VARCHAR, INEP_DTPUBL_REC, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTDESPACHO_REC, 103)) END)
				   END) END) AS INEP_DOC, -- adicionado Gustavo
				   a.PESSOA AS CODIGO,
				   '' AS TURNO,
                   p.NACIONALIDADE AS NACIONALIDADE,
                   (SELECT NOME FROM dbo.MUNICIPIO WHERE CODIGO = p.MUNICIPIO_NASC) AS NATURAL_ESTADO,
                   p.DT_NASC AS DATA_NASCIMENTO,
                   (CASE
                        WHEN p.NACIONALIDADE = 'BRASILEIRA' THEN ('RG - ' + p.RG_NUM + Space(5) + p.RG_EMISSOR) 
                        ELSE (CASE 
                                  WHEN p.RG_TIPO = 'RNE' THEN ('RNE - ' + p.RG_NUM) 
                                  ELSE ('PASSAPORTE - ' + p.PASSAPORTE)
                              END)
          END) AS DOCUMENTO,
				   a.OUTRA_FACULDADE AS ESTABELECIMENTO_2G,
				   '' AS LOCAL_2G,
				   a.ANOCONCL_2G,
                   vest.DTVEST AS DATA_VESTIBULAR,
				   a.TIPO_INGRESSO, -- adicionado Gustavo
				   a.ANO_INGRESSO, -- adicionado Gustavo
				   a.CURRICULO, -- adicionado Gustavo
                   vest.CLASSIFICACAO AS CLASSIFICACAO_VEST,
				   --ISNULL(f1.NOME_COMP, f2.NOME_COMP) AS NOME_FACULDADE_VEST,
				   f1.NOME_COMP AS NOME_FACULDADE_VEST,
				   f1.FACULDADE,  -- adicionado Gustavo
				   it.DESCR, -- adicionado Gustavo
				   '' AS PROVAVEST,
				   '' AS NOTA_PADRONIZADA,
                   /*CASE
                       WHEN m.ANO > a.ANO_INGRESSO THEN CAST(m.SEMESTRE AS VARCHAR(2)) + '/' + CAST(m.ANO AS VARCHAR(4))
                       WHEN m.ANO < a.ANO_INGRESSO THEN CAST(a.SEM_INGRESSO AS VARCHAR(2)) + '/' + CAST(a.ANO_INGRESSO AS VARCHAR(4))
                       WHEN m.ANO = a.ANO_INGRESSO THEN
                            CASE WHEN m.SEMESTRE >= a.SEM_INGRESSO THEN CAST(m.SEMESTRE AS VARCHAR(2)) + '/' + CAST(m.ANO AS VARCHAR(4))
                            ELSE CAST(a.SEM_INGRESSO AS VARCHAR(2)) + '/' + CAST(m.ANO AS VARCHAR(4))
                            END
                   END AS CAMPO_ORDENACAO,*/ CAST(m.SEMESTRE AS VARCHAR(1)) + '/' + CAST(m.ANO AS VARCHAR(4)) AS CAMPO_ORDENACAO,
                   m.DISCIPLINA AS COD_DISC,
                   d.NOME_COMPL AS NOME_DISC,
				   do.NOME_COMPL AS NOME_COMPL, -- adicionado Gustavo
				   CASE
                       WHEN UPPER(do.TITULACAO) = 'MESTRADO COMPLETO' THEN 'MESTRE'
					   WHEN UPPER(do.TITULACAO) = 'MESTRADO' THEN 'MESTRE'
                       WHEN UPPER(do.TITULACAO) = 'MESTRADO INCOMPLETO' THEN 'MESTRE'
					   WHEN UPPER(do.TITULACAO) = 'PÓS GRAD. COMPLETO'  THEN 'ESPECIALISTA'
					   WHEN UPPER(do.TITULACAO) = 'ESPECIALIZACAO'  THEN 'ESPECIALISTA'
					   WHEN UPPER(do.TITULACAO) = 'DOUTORADO COMPLETO' THEN 'DOUTOR'
					   WHEN UPPER(do.TITULACAO) = 'DOUTORADO' THEN 'DOUTOR'
					   WHEN UPPER(do.TITULACAO) = 'DOUTORADO INCOMPLETO' THEN 'DOUTOR'
					   WHEN UPPER(do.TITULACAO) = 'SUPERIOR COMPLETO' THEN 'GRADUADO'
					   WHEN UPPER(do.TITULACAO) = 'SUPERIOR' THEN 'GRADUADO'
					   ELSE UPPER(do.TITULACAO)
				   END,
                   --CAST (m.SEMESTRE AS VARCHAR(2)) + '/' + CAST (m.ANO AS VARCHAR(4)) AS PERIODO_LETIVO,
                   CAST (m.ANO AS VARCHAR(4)) + '.' + CAST (m.SEMESTRE AS VARCHAR(1)) AS PERIODO_LETIVO,
                   a.SERIE AS SEMESTRE_ALUNO,
				   0 AS SERIE_IDEAL, --g.SERIE_IDEAL,
                   0 AS CREDITOS, --d.CREDITOS AS CREDITOS,
                   --d.HORAS_AULA AS CARGA_HORARIA,
                   d.HORAS_AULA,  --d.HORAS_AULA, -- adicionado Gustavo
				   d.HORAS_LAB, -- adicionado Gustavo
				   d.HORAS_ATIV, -- adicionado Gustavo
				    (
					SELECT SUM(d1.HORAS_AULA + d1.HORAS_LAB + d1.HORAS_ATIV) FROM LY_DISCIPLINA d1 -- HORAS_AULA + HORAS_LAB + HORAS_ATIV
					WHERE d1.DISCIPLINA = d.DISCIPLINA
				   ) AS CARGA_HORARIA,
				   ISNULL(dbo.fnRelatHistOficialNotaFinal(m.ALUNO, m.ORDEM, m.ANO, m.SEMESTRE, m.DISCIPLINA, 2), 0) AS MEDIA_FINAL,
                   ISNULL(m.NOTA_FINAL, '0') AS MEDIA_FINAL_HM,
                   /*CASE -- alterado Gustavo
                       WHEN UPPER(m.SITUACAO_HIST) = 'DISPENSADO' THEN 'Aproveit. Estudos'
                       WHEN ISNUMERIC(m.NOTA_FINAL) = 1 THEN
                            CASE
								WHEN CAST(REPLACE(m.NOTA_FINAL,',','.') AS FLOAT) < 6 THEN 'Rep Nota'
								ELSE m.SITUACAO_HIST
							END
                       ELSE m.SITUACAO_HIST
                   END AS OBSERVACOES, */
				   m.SITUACAO_HIST AS OBSERVACOES,
				   CASE
                       WHEN m.SITUACAO_HIST  = 'Aprovado' THEN (SELECT SUM(d1.HORAS_AULA + d1.HORAS_LAB + d1.HORAS_ATIV) FROM LY_DISCIPLINA d1 WHERE d1.DISCIPLINA = d.DISCIPLINA)
					   WHEN m.SITUACAO_HIST = 'Dispensado' THEN ((SELECT SUM(d1.HORAS_AULA + d1.HORAS_LAB + d1.HORAS_ATIV) FROM LY_DISCIPLINA d1 WHERE d1.DISCIPLINA = d.DISCIPLINA))
					   ELSE 0
				   END as CH_CUMPRIDA,
				   (SELECT VALOR FROM LY_INDICE_ALUNO ind WHERE ind.ALUNO = a.ALUNO AND ind.INDICE LIKE @p_indice_semestral + '-' + CAST(m.ANO AS VARCHAR(4)) + '/' + CAST(m.SEMESTRE AS VARCHAR(1)) + '%') AS MEDIA_SEMESTRAL,
                   (SELECT VALOR FROM LY_INDICE_ALUNO ind WHERE ind.ALUNO = a.ALUNO AND ind.INDICE = (@p_indice_media_geral + '-' + @MAX_ANO + '/' + @MAX_PERIODO)) AS MEDIA_GERAL_CURSO,
                   dbo.fnRelatHistMatricObsExtra(a.ALUNO) AS OBS_HISTORICO,
                   cconcl.DT_COLACAO AS COLACAO_GRAU,
                   cconcl.DT_DIPLOMA AS EXPD_DIPLOMA,
				   cconcl.DT_ENCERRAMENTO AS DT_CONCLUSAO,
				   NULL AS DT_ENEM,
                   CAST(dbo.fnRelatGetHoras (a.ALUNO, 'CH') AS VARCHAR(6)) + ' + ' + CAST(dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO') AS VARCHAR(6)) + ' (ESTÁGIO) = ' + CAST ((dbo.fnRelatGetHoras (a.ALUNO, 'CH') + dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO')) AS VARCHAR(6)) AS CARGA_HORARIA_ESTAGIO,
                   CASE WHEN dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO') > 0 THEN 'S' ELSE 'N' END AS ESTAGIO_SN,
				   p.NOME_PAI,
				   p.NOME_MAE,
				   p.RG_NUM,
				   p.RG_EMISSOR,
				   p.RG_UF, -- incluido Gustavo
				   p.CPF, -- incluido Gustavo
				   p.ALIST_NUM,
				   p.ALIST_RM,
				   p.ALIST_SERIE,
				   p.DT_NASC,
				   mun.NOME AS MUNICIPIO_UNIDADE,
				   mu.NOME AS MUNICIPIO_NASC,
				   p.TELEITOR_NUM,
				   p.TELEITOR_ZONA,
				   p.TELEITOR_SECAO   
            FROM LY_HISTMATRICULA m INNER JOIN
                 VW_ALUNO a ON m.ALUNO = a.ALUNO INNER JOIN
                 LY_DISCIPLINA d ON m.DISCIPLINA = d.DISCIPLINA INNER JOIN
                 LY_TURMA hd ON d.DISCIPLINA = hd.DISCIPLINA AND hd.ANO = m.ANO AND hd.SEMESTRE = m.SEMESTRE INNER JOIN  -- adicionado Gustavo
				 LY_DOCENTE do ON hd.NUM_FUNC = do.NUM_FUNC INNER JOIN -- adicionado Gustavo
				 VW_CURSO c ON a.CURSO = c.CURSO LEFT JOIN
                 LY_H_CURSOS_CONCL cconcl ON a.ALUNO = cconcl.ALUNO AND a.CURSO = cconcl.CURSO AND a.TURNO = cconcl.TURNO AND a.CURRICULO = cconcl.CURRICULO LEFT JOIN
                 LY_PESSOA p ON a.PESSOA = p.PESSOA LEFT JOIN
                 LY_UNIDADE_ENSINO ue ON ue.UNIDADE_ENS = c.FACULDADE LEFT JOIN
				 MUNICIPIO mun ON mun.CODIGO = ue.MUNICIPIO LEFT JOIN
				 MUNICIPIO mu ON p.MUNICIPIO_NASC = mu.CODIGO LEFT JOIN
				 MUNICIPIO mn ON a.CIDADE_2G = mn.CODIGO LEFT JOIN
				 LY_DADOS_VESTIBULAR vest ON a.ALUNO = vest.ALUNO LEFT JOIN
				 LY_FACULDADE f1 ON vest.OUTRA_FACULDADE = f1.FACULDADE LEFT JOIN
				 ITEMTABELA it ON f1.FACULDADE = it.item  -- adicionado Gustavo
            WHERE c.FACULDADE = CASE WHEN @p_unidade IS NULL THEN c.FACULDADE ELSE @p_unidade END AND
                  c.TIPO = CASE WHEN @p_tipo IS NULL THEN c.TIPO ELSE @p_tipo END AND
                  a.CURSO =  CASE WHEN @p_curso IS NULL THEN a.CURSO ELSE @p_curso END AND
                  --a.ANO_INGRESSO = CASE WHEN @p_ano IS NULL THEN a.ANO_INGRESSO ELSE @p_ano END AND
                  --a.SEM_INGRESSO = CASE WHEN @p_periodo IS NULL THEN a.SEM_INGRESSO ELSE @p_periodo END AND
                  a.ALUNO = CASE WHEN @p_aluno IS NULL THEN a.ALUNO ELSE @p_aluno END AND
                 -- a.PESSOA = CASE WHEN @p_pessoa IS NULL THEN a.PESSOA ELSE @p_pessoa END AND
                  d.ESTAGIO = 'N'
			


			UNION

				SELECT TOP 100 PERCENT 
				ISNULL(a.NOME_SOCIAL, a.NOME_COMPL) AS NOME_ALUNO,
				a.ALUNO AS MATRICULA,
				c.NOME, -- adicionado Gustavo
				c.HABILITACAO, -- adicionado Gustavo
				c.DECRETO, -- adicionado Gustavo
				c.INEP_CURSO, -- adicionado Gustavo
				c.CURSO,-- adicionado Gustavo
				c.TITULO, -- adicionado Gustavo
				(CASE WHEN INEP_TIPODOC_REC IS NULL THEN ('Curso criado pela ' + INEP_TIPODOC_CRIACAO  + ', de ' + CONVERT(VARCHAR, INEP_DTDESPACHO_CRIACAO, 103)) ELSE
				(CASE WHEN INEP_TIPODOC_REC IS NOT NULL AND INEP_TIPODOC_RENOV IS NOT NULL  THEN ('Curso reconhecido pelo ' + INEP_TIPODOC_REC + ' nº ' + INEP_NUMDOC_REC + ', de ' + CONVERT(VARCHAR, INEP_DTPUBL_REC, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTDESPACHO_REC, 103) + ' renovado o reconhecimento pela ' + INEP_TIPODOC_RENOV + ' nº ' + INEP_NUMDOC_RENOV + ', de ' + CONVERT(VARCHAR,INEP_DTDESPACHO_RENOV, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTPUBL_RENOV, 103)) ELSE
				(CASE WHEN INEP_TIPODOC_REC IS NOT NULL THEN ('Curso reconhecido pelo ' + INEP_TIPODOC_REC + ' nº ' + INEP_NUMDOC_REC + ', de ' + CONVERT(VARCHAR, INEP_DTPUBL_REC, 103) + ' - DOU: ' + CONVERT(VARCHAR,INEP_DTDESPACHO_REC, 103)) END)
				END) END) AS INEP_DOC, -- adicionado Gustavo
				a.PESSOA AS CODIGO,
				' ' AS TURNO,
				p.NACIONALIDADE AS NACIONALIDADE,
				(SELECT NOME FROM dbo.MUNICIPIO WHERE CODIGO = p.MUNICIPIO_NASC) AS NATURAL_ESTADO,
				p.DT_NASC AS DATA_NASCIMENTO,
				(CASE
					WHEN p.NACIONALIDADE = 'BRASILEIRA' THEN ('RG - ' + p.RG_NUM + Space(5) + p.RG_EMISSOR) 
					ELSE (CASE 
					WHEN p.RG_TIPO = 'RNE' THEN ('RNE - ' + p.RG_NUM) 
					ELSE ('PASSAPORTE - ' + p.PASSAPORTE)
					END)
				END) AS DOCUMENTO,
				a.OUTRA_FACULDADE AS ESTABELECIMENTO_2G,
				' ' AS LOCAL_2G,
				a.ANOCONCL_2G,
				vest.DTVEST AS DATA_VESTIBULAR,
				a.TIPO_INGRESSO, -- adicionado Gustavo
				a.ANO_INGRESSO, -- adicionado Gustavo
				a.CURRICULO, -- adicionado Gustavo
				vest.CLASSIFICACAO AS CLASSIFICACAO_VEST,
				--ISNULL(f1.NOME_COMP, f2.NOME_COMP) AS NOME_FACULDADE_VEST,
				f1.NOME_COMP AS NOME_FACULDADE_VEST,
				f1.FACULDADE,  -- adicionado Gustavo
				' ' AS DESCR, -- adicionado Gustavo
				' ' AS PROVAVEST,
				' ' AS NOTA_PADRONIZADA,
				' ' AS CAMPO_ORDENACAO,
				d.DISCIPLINA AS COD_DISC,
				d.NOME_COMPL AS NOME_DISC,
				' ' AS NOME_COMPL, -- adicionado Gustavo
				' ' AS TITULACAO, 
				--CAST (m.SEMESTRE AS VARCHAR(2)) + '/' + CAST (m.ANO AS VARCHAR(4)) AS PERIODO_LETIVO,
				'99999' AS PERIODO_LETIVO,
				a.SERIE AS SEMESTRE_ALUNO,
				g.SERIE_IDEAL,
				d.CREDITOS AS CREDITOS,
				--d.HORAS_AULA AS CARGA_HORARIA,
				d.HORAS_AULA, -- adicionado Gustavo
				d.HORAS_LAB, -- adicionado Gustavo
				d.HORAS_ATIV, -- adicionado Gustavo
				(SELECT SUM(d1.HORAS_AULA + d1.HORAS_LAB + d1.HORAS_ATIV) FROM LY_DISCIPLINA d1 -- HORAS_AULA + HORAS_LAB + HORAS_ATIV
					WHERE d1.DISCIPLINA = d.DISCIPLINA
				) AS CARGA_HORARIA,
				0 AS MEDIA_FINAL,
				0 AS MEDIA_FINAL_HM,
				'DP' AS OBSERVACOES,
				0 AS CH_CUMPRIDA,
				NULL AS MEDIA_SEMESTRAL,
				NULL AS MEDIA_GERAL_CURSO,
				dbo.fnRelatHistMatricObsExtra(a.ALUNO) AS OBS_HISTORICO,
				' ' AS COLACAO_GRAU,
				' ' AS EXPD_DIPLOMA,
				' ' AS DT_CONCLUSAO,
				NULL AS DT_ENEM,
				CAST(dbo.fnRelatGetHoras (a.ALUNO, 'CH') AS VARCHAR(6)) + ' + ' + CAST(dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO') AS VARCHAR(6)) + ' (ESTÁGIO) = ' + CAST ((dbo.fnRelatGetHoras (a.ALUNO, 'CH') + dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO')) AS VARCHAR(6)) AS CARGA_HORARIA_ESTAGIO,
				CASE WHEN dbo.fnRelatGetHoras (a.ALUNO, 'ESTAGIO') > 0 THEN 'S' ELSE 'N' END AS ESTAGIO_SN,
				p.NOME_PAI,
				p.NOME_MAE,
				p.RG_NUM,
				p.RG_EMISSOR,
				p.RG_UF,
				p.CPF, -- incluido Gustavo
				p.ALIST_NUM,
				p.ALIST_RM,
				p.ALIST_SERIE,
				p.DT_NASC,
				' ' AS MUNICIPIO_UNIDADE,
				' ' AS MUNICIPIO_NASC,
				p.TELEITOR_NUM,
				p.TELEITOR_ZONA,
				p.TELEITOR_SECAO
			FROM LY_ALUNO a (NOLOCK)   
			INNER JOIN LY_CURSO c (NOLOCK)      
			 ON c.CURSO = a.CURSO      

			INNER JOIN LY_FACULDADE f1 (NOLOCK)      
			 ON f1.FACULDADE = c.FACULDADE  
    
			INNER JOIN LY_PESSOA p (NOLOCK)       
			 ON p.PESSOA = a.PESSOA      
 
			INNER JOIN LY_CURRICULO LYC (NOLOCK)      
			 ON LYC.CURSO = a.CURSO      
			 AND LYC.TURNO = a.TURNO   
			 AND LYC.CURRICULO = a.CURRICULO   
   
			INNER JOIN LY_GRADE g (NOLOCK)  
			 ON a.CURSO = g.CURSO      
			 AND a.TURNO = g.TURNO      
			 AND a.CURRICULO = g.CURRICULO    
  
			INNER JOIN LY_DISCIPLINA d (NOLOCK)      
			 ON d.DISCIPLINA = g.DISCIPLINA      

			LEFT JOIN LY_DADOS_HIST DH (NOLOCK)      
			 ON DH.ALUNO = a.ALUNO      

			LEFT JOIN LY_DADOS_VESTIBULAR vest (NOLOCK)      
			 ON a.ALUNO = vest.ALUNO   
				AND a.CURSO = vest.CURSO   

			LEFT JOIN (select * from LY_H_CURSOS_CONCL where motivo='Conclusão') LYHC      
			 ON a.ALUNO = LYHC.ALUNO
				AND a.CURSO = LYHC.CURSO      

			LEFT JOIN MUNICIPIO M (NOLOCK)      
			 ON M.CODIGO = p.MUNICIPIO_NASC

			----------------------------------------- Marcus
			LEFT JOIN UF (NOLOCK)      
			 ON M.UF_SIGLA  = UF.SIGLA

			LEFT JOIN LY_INSTITUICAO ITC
			ON a.INSTITUICAO = ITC.OUTRA_FACULDADE
			-----------------------------------------      

			LEFT JOIN MUNICIPIO M2G (NOLOCK)      
			 ON M2G.CODIGO = a.CIDADE_2G

			WHERE NOT EXISTS      
			(      
			 SELECT 1      
			 FROM LY_HISTMATRICULA LYH (NOLOCK)      
			 WHERE LYH.ALUNO = a.ALUNO      
			 AND LYH.DISCIPLINA = g.DISCIPLINA      
			 AND LYH.SITUACAO_HIST not in ('Rep Nota','Rep Freq','Cancelado','Trancado') --by kleber 15.02.2016 Mostrara as disciplinas trancadas como não cursada)
			)      
			AND NOT EXISTS      
			(      
			 SELECT 1      
			 FROM LY_MATRICULA LYM (NOLOCK)      
			 WHERE LYM.ALUNO = a.ALUNO      
			 AND LYM.DISCIPLINA = g.DISCIPLINA      
			)      
			AND  NOT EXISTS      
			 (      
			-- SELECT 1      
			-- FROM LY_HISTMATRICULA LYH (NOLOCK) 
			-- WHERE LYH.ALUNO = LYA.ALUNO      
			-- AND g.FORMULA_EQUIV LIKE '%' + LYH.DISCIPLINA + '%'      
			select 1
				from uniev_historico_aux_equivalencia eq
				where	eq.aluno = a.aluno
						and	eq.disciplina_equiv = g.disciplina
						and eq.equivalente=1
			 )  
			 AND NOT EXISTS 
			 (select 1
				from uniev_historico_aux_equivalencia eq
				where		eq.aluno = a.aluno
						and	eq.disciplina_equiv = g.disciplina
						and eq.equivalente=1
						)

			AND a.ALUNO = @p_aluno   




            SELECT * FROM #HISTOFICIAL
            ORDER BY NOME_ALUNO, RIGHT(PERIODO_LETIVO, 4), LEFT(PERIODO_LETIVO, 1), COD_DISC


			


END;


