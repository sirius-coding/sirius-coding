# sirius-xz-agent pgvector RAG Design

## Goal

Upgrade `sirius-xz-agent` from a rule-based retrieval sample into a real RAG scaffold:

- documents can be ingested and stored
- documents are split into chunks
- chunks are embedded and persisted
- retrieval uses PostgreSQL + `pgvector`
- answer generation still uses DeepSeek when enabled
- the project keeps a local fallback path so it remains runnable without external services

## Non-Goals

- multi-tenant isolation
- authentication and authorization
- document versioning
- streaming responses
- complex agent workflows
- multiple vector backends in the first iteration

## Proposed Architecture

Keep the current web and service boundaries, but add a real ingestion and vector retrieval layer.

### Core Layers

- `KnowledgeController`
  - exposes document CRUD and ingestion endpoints
- `KnowledgeIngestionService`
  - accepts a document
  - splits it into chunks
  - prepares embeddings
  - stores chunk records
- `EmbeddingService`
  - generates embedding vectors for questions and chunks
  - delegates to a real model when available
  - falls back to a local deterministic implementation when needed
- `PostgresVectorStore`
  - persists chunks and embeddings
  - performs similarity search with `pgvector`
- `RetrievalService`
  - resolves the top-k chunks
  - turns chunk hits into structured retrieval results
- `StructuredAnswerGenerator`
  - produces the final answer text
  - uses DeepSeek when enabled
  - falls back to the current local answer generator otherwise

### New Data Model

- `KnowledgeDocument`
  - the public business document
- `DocumentChunk`
  - a chunk produced by ingestion
  - contains document id, chunk index, chunk text, and tags
- `ChunkEmbedding`
  - internal persistence record for chunk text plus vector

## Data Flow

1. A user submits a knowledge document.
2. `KnowledgeIngestionService` splits the document into chunks.
3. `EmbeddingService` creates an embedding for each chunk.
4. `PostgresVectorStore` stores the chunk text and vector in PostgreSQL.
5. When a question arrives, `EmbeddingService` converts the question into a vector.
6. `PostgresVectorStore` runs Top-K similarity search.
7. `RetrievalService` converts hits into retrieval context.
8. `StructuredAnswerGenerator` produces the final answer.

## PostgreSQL Schema

Use a small, explicit schema for the first version.

### Table: `knowledge_chunk`

- `id` `bigserial` primary key
- `document_id` `varchar`
- `document_title` `varchar`
- `chunk_index` `integer`
- `chunk_text` `text`
- `tags` `text[]`
- `embedding` `vector(...)`
- `created_at` `timestamp`

The exact vector dimension will follow the embedding model used by the implementation.

## Fallback Strategy

The project must remain runnable without external services.

- If DeepSeek is disabled, `LocalStructuredAnswerGenerator` stays active.
- If PostgreSQL or `pgvector` is unavailable, the project should keep an in-memory retrieval path for local development.
- If the embedding model is unavailable, embeddings can fall back to a deterministic local vector so the code path still works in tests.

## Configuration

Add a compact configuration surface:

- `SIRIUS_AI_DEEPSEEK_ENABLED`
- `DEEPSEEK_API_KEY`
- `DEEPSEEK_MODEL`
- `SIRIUS_VECTORSTORE_ENABLED`
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

## Endpoint Impact

Keep the current public API shape and extend it carefully:

- `POST /api/knowledge/documents`
  - persists a document and triggers chunk ingestion
- `GET /api/knowledge/documents`
  - lists known documents
- `GET /api/knowledge/documents/{id}`
  - returns one document or `404`
- `GET /api/agent/ask`
  - resolves retrieval context and returns a structured answer

## Error Handling

- Invalid document payloads return validation errors.
- Missing documents return `404`.
- Vector store failures should fall back to the in-memory path when possible.
- DeepSeek failures should not break the whole application if the local fallback is available.
- Retrieval with no hits should return the current “no related material found” message.

## Testing Strategy

Write tests in this order:

1. chunk splitting behavior
2. vector store write and Top-K retrieval
3. ingestion to retrieval flow
4. DeepSeek generator injection and fallback selection
5. controller smoke tests for document CRUD and ask flow

Use offline smoke tests where network access or Maven plugin download is unavailable.

## First Iteration Scope

The first implementation pass should include:

- PostgreSQL table and repository
- document chunking
- embedding generation abstraction
- vector retrieval implementation
- answer generation wiring
- README and configuration updates

The first pass should not include:

- UI
- user management
- multi-tenant routing
- background reindex jobs
- cache invalidation policies
- vector backend abstraction beyond PostgreSQL

## Success Criteria

- `sirius-xz-agent` can ingest a document and store chunk records in PostgreSQL.
- a question can be answered with Top-K vector retrieval context.
- DeepSeek can be enabled through configuration.
- the project still starts and runs with local fallback only.
- tests cover the ingestion and retrieval path.
