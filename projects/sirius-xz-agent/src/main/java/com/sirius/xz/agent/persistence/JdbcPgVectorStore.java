package com.sirius.xz.agent.persistence;

import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

public class JdbcPgVectorStore implements PgVectorStore {

    private final JdbcTemplate jdbcTemplate;

    public JdbcPgVectorStore(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void save(KnowledgeChunkRow row) {
        jdbcTemplate.update(connection -> {
            java.sql.PreparedStatement statement = connection.prepareStatement("""
                insert into knowledge_chunk (
                    document_id,
                    document_title,
                    chunk_index,
                    chunk_text,
                    tags,
                    embedding
                ) values (?, ?, ?, ?, ?, ?::vector)
                on conflict (document_id, chunk_index) do update
                set document_title = excluded.document_title,
                    chunk_text = excluded.chunk_text,
                    tags = excluded.tags,
                    embedding = excluded.embedding
                """);
            statement.setString(1, row.documentId());
            statement.setString(2, row.documentTitle());
            statement.setInt(3, row.chunkIndex());
            statement.setString(4, row.chunkText());
            statement.setArray(5, toTextArray(connection, row.tags()));
            statement.setString(6, PgVectorSql.toVectorLiteral(row.embedding()));
            return statement;
        });
    }

    @Override
    public void saveAll(List<KnowledgeChunkRow> rows) {
        rows.forEach(this::save);
    }

    @Override
    public List<ChunkSearchResult> search(float[] queryVector, int limit) {
        return jdbcTemplate.query("""
                select
                    document_id,
                    document_title,
                    chunk_index,
                    chunk_text,
                    tags,
                    embedding,
                    1.0 / (1.0 + (embedding <-> ?::vector)) as similarity
                from knowledge_chunk
                order by embedding <-> ?::vector
                limit ?
                """,
            rowMapper(),
            PgVectorSql.toVectorLiteral(queryVector),
            PgVectorSql.toVectorLiteral(queryVector),
            limit);
    }

    @Override
    public void deleteByDocumentId(String documentId) {
        jdbcTemplate.update("delete from knowledge_chunk where document_id = ?", documentId);
    }

    private Array toTextArray(Connection connection, List<String> tags) throws SQLException {
        return connection.createArrayOf("text", tags.toArray(String[]::new));
    }

    private RowMapper<ChunkSearchResult> rowMapper() {
        return (resultSet, rowNum) -> new ChunkSearchResult(
            resultSet.getString("document_id"),
            resultSet.getString("document_title"),
            resultSet.getInt("chunk_index"),
            resultSet.getString("chunk_text"),
            List.of((String[]) resultSet.getArray("tags").getArray()),
            resultSet.getDouble("similarity")
        );
    }
}
