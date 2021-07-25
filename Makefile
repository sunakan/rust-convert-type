.PHONY: db
db: ## dbコンテナとブラウザクライアントを立てる
	docker-compose up -d db
	docker-compose up -d db-2nd
	docker-compose up -d pgweb

.PHONY: down
down: ## コンテナを落とす
	docker-compose down

.PHONY: clean
clean: ## コンテナを落とす(volumeも)
	docker-compose down --volume

################################################################################
# PostgreSQL
################################################################################
.PHONY: sample-data
sample-data: ## DBにサンプルデータを入れる（まとめ）
	@make sample-data-for-db
	@make sample-data-for-db-2nd

.PHONY: sample-data-for-db
sample-data-for-db: ## DBにサンプルデータを入れる
	docker-compose exec db sh -c "psql -hlocalhost -Uhoge-user -dhoge-db -c \"TRUNCATE users, microposts RESTART IDENTITY;\""
	docker-compose exec db sh -c "psql -hlocalhost -Uhoge-user -dhoge-db -c \"INSERT INTO users (name, email) VALUES ('名無しの権兵衛01', 'test01@example.com') RETURNING id,name,email,created_at,updated_at;\""
	docker-compose exec db sh -c "psql -hlocalhost -Uhoge-user -dhoge-db -c \"INSERT INTO users (name, email) VALUES ('名無しの権兵衛02', 'test02@example.com') RETURNING id,name,email,created_at,updated_at;\""
	docker-compose exec db sh -c "psql -hlocalhost -Uhoge-user -dhoge-db -c \"INSERT INTO users (name, email) VALUES ('名無しの権兵衛03', 'test03@example.com') RETURNING id,name,email,created_at,updated_at;\""
	docker-compose exec db sh -c "psql -hlocalhost -Uhoge-user -dhoge-db -c \"SELECT * FROM users;\""
	sleep 5
	docker-compose exec db sh -c "psql -hlocalhost -Uhoge-user -dhoge-db -c \"UPDATE users SET name = '福沢諭吉' WHERE id = 1 RETURNING id,name,email,created_at,updated_at;\""
	docker-compose exec db sh -c "psql -hlocalhost -Uhoge-user -dhoge-db -c \"SELECT * FROM users;\""

.PHONY: sample-data-for-db-2nd
sample-data-for-db-2nd: ## DB-2ndにサンプルデータを入れる
	docker-compose exec db-2nd sh -c "psql -hlocalhost -p5433 -Uhoge-user -dhoge-db -c \"TRUNCATE users, microposts RESTART IDENTITY;\""
	docker-compose exec db-2nd sh -c "psql -hlocalhost -p5433 -Uhoge-user -dhoge-db -c \"INSERT INTO users (name, email) VALUES ('田中太郎01', 'taro01@example.com') RETURNING id,name,email,created_at,updated_at;\""
	docker-compose exec db-2nd sh -c "psql -hlocalhost -p5433 -Uhoge-user -dhoge-db -c \"INSERT INTO users (name, email) VALUES ('田中太郎02', 'taro02@example.com') RETURNING id,name,email,created_at,updated_at;\""
	docker-compose exec db-2nd sh -c "psql -hlocalhost -p5433 -Uhoge-user -dhoge-db -c \"INSERT INTO users (name, email) VALUES ('田中太郎03', 'taro03@example.com') RETURNING id,name,email,created_at,updated_at;\""
	docker-compose exec db-2nd sh -c "psql -hlocalhost -p5433 -Uhoge-user -dhoge-db -c \"SELECT * FROM users;\""
	sleep 5
	docker-compose exec db-2nd sh -c "psql -hlocalhost -p5433 -Uhoge-user -dhoge-db -c \"UPDATE users SET name = '樋口一葉' WHERE id = 1 RETURNING id,name,email,created_at,updated_at;\""
	docker-compose exec db-2nd sh -c "psql -hlocalhost -p5433 -Uhoge-user -dhoge-db -c \"SELECT * FROM users;\""


################################################################################
# Utility-Command help
################################################################################
.DEFAULT_GOAL := help

################################################################################
# マクロ
################################################################################
# Makefileの中身を抽出してhelpとして1行で出す
# $(1): Makefile名
define help
  grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(1) \
  | grep --invert-match "## non-help" \
  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
endef
################################################################################
# タスク
################################################################################
.PHONY: help
help: ## Make タスク一覧
	@echo '######################################################################'
	@echo '# Makeタスク一覧'
	@echo '# $$ make XXX'
	@echo '# or'
	@echo '# $$ make XXX --dry-run'
	@echo '######################################################################'
	@echo $(MAKEFILE_LIST) \
	| tr ' ' '\n' \
	| xargs -I {included-makefile} $(call help,{included-makefile})
