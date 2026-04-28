.PHONY: help setup build test run clean \
        db-up db-down db-clean db-logs db-connect db-reset restart \
        compile package install install-with-tests \
        test-unit test-integration \
        start dev ci \
        clean-all fresh-install \
        status dependencies \
        gen-jwt \
        push pull git-status sync

# ============================================================
# Variables
# ============================================================
COMPOSE    = docker compose --env-file .env
DB_NAME    = $(shell grep ^DB_NAME .env 2>/dev/null | cut -d= -f2 | tr -d ' ' || echo billwise_dev)
DB_USER    = $(shell grep ^DB_USER .env 2>/dev/null | cut -d= -f2 | tr -d ' ' || echo billwise)
DB_PORT    = $(shell grep ^DB_PORT .env 2>/dev/null | cut -d= -f2 | tr -d ' ' || echo 5432)
BRANCH     = $(shell git branch --show-current 2>/dev/null || echo main)
EXPORT_ENV = export $$(grep -v '^\#' .env | grep -v '^\s*$$' | xargs) &&

# ============================================================
# Colores
# ============================================================
BLUE   = \033[0;34m
GREEN  = \033[0;32m
YELLOW = \033[1;33m
RED    = \033[0;31m
NC     = \033[0m

# ============================================================
# AYUDA
# ============================================================

help:
	@echo "$(BLUE)══════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)             BILLWISE API — Comandos Make             $(NC)"
	@echo "$(BLUE)══════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(GREEN)PRIMERA VEZ:$(NC)"
	@echo "  $(YELLOW)make setup$(NC)             - Setup completo del proyecto"
	@echo "  $(YELLOW)make db-up$(NC)             - Levantar PostgreSQL"
	@echo "  $(YELLOW)make run$(NC)               - Ejecutar aplicación"
	@echo ""
	@echo "$(GREEN)RÁPIDO:$(NC)"
	@echo "  $(YELLOW)make start$(NC)             - db-up + compile + run"
	@echo "  $(YELLOW)make dev$(NC)               - Inicio rápido de desarrollo"
	@echo ""
	@echo "$(GREEN)DESARROLLO DIARIO:$(NC)"
	@echo "  $(YELLOW)make compile$(NC)           - Compilar sin tests"
	@echo "  $(YELLOW)make test$(NC)              - Ejecutar todos los tests"
	@echo "  $(YELLOW)make test-unit$(NC)         - Solo tests unitarios"
	@echo "  $(YELLOW)make test-integration$(NC)  - Solo tests de integración"
	@echo ""
	@echo "$(GREEN)BASE DE DATOS:$(NC)"
	@echo "  $(YELLOW)make db-up$(NC)             - Levantar PostgreSQL"
	@echo "  $(YELLOW)make db-down$(NC)           - Detener servicios"
	@echo "  $(YELLOW)make db-clean$(NC)          - Eliminar contenedores y volúmenes"
	@echo "  $(YELLOW)make db-logs$(NC)           - Ver logs en tiempo real"
	@echo "  $(YELLOW)make db-connect$(NC)        - Conectar a PostgreSQL (psql)"
	@echo "  $(YELLOW)make db-reset$(NC)          - Resetear base de datos"
	@echo "  $(YELLOW)make restart$(NC)           - Reiniciar servicios Docker"
	@echo ""
	@echo "$(GREEN)BUILD:$(NC)"
	@echo "  $(YELLOW)make compile$(NC)           - Compilar sin tests"
	@echo "  $(YELLOW)make package$(NC)           - Generar JAR"
	@echo "  $(YELLOW)make install$(NC)           - Instalar en repo Maven local"
	@echo "  $(YELLOW)make ci$(NC)               - compile + test + package"
	@echo ""
	@echo "$(GREEN)LIMPIEZA:$(NC)"
	@echo "  $(YELLOW)make clean$(NC)             - Limpiar archivos Maven"
	@echo "  $(YELLOW)make clean-all$(NC)         - Limpieza profunda"
	@echo "  $(YELLOW)make fresh-install$(NC)     - Reinstalar desde cero"
	@echo ""
	@echo "$(GREEN)UTILIDADES:$(NC)"
	@echo "  $(YELLOW)make status$(NC)            - Estado de servicios Docker"
	@echo "  $(YELLOW)make gen-jwt$(NC)           - Genera JWT_SECRET seguro"
	@echo "  $(YELLOW)make dependencies$(NC)      - Árbol de dependencias"
	@echo ""
	@echo "$(GREEN)GIT:$(NC)"
	@echo "  $(YELLOW)make push m='mensaje'$(NC)  - Add + Commit + Push"
	@echo "  $(YELLOW)make pull$(NC)              - Pull desde origin"
	@echo "  $(YELLOW)make git-status$(NC)        - Estado del repositorio"
	@echo "  $(YELLOW)make sync m='mensaje'$(NC)  - Pull + Commit + Push"
	@echo ""

# ============================================================
# SETUP INICIAL
# ============================================================

setup:
	@echo "$(BLUE)══════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)           SETUP INICIAL — BILLWISE API              $(NC)"
	@echo "$(BLUE)══════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(YELLOW)Paso 1/4:$(NC) Verificando archivo .env..."
	@test -f .env || ( \
		echo "$(RED)ERROR: .env no encontrado$(NC)" && \
		echo "$(YELLOW)Ejecuta: cp .env.example .env$(NC)" && \
		exit 1 \
	)
	@echo "$(GREEN)  OK .env existe$(NC)"
	@echo ""
	@echo "$(YELLOW)Paso 2/4:$(NC) Descargando dependencias Maven..."
	@./mvnw dependency:resolve dependency:resolve-plugins -q
	@echo "$(GREEN)  OK Dependencias descargadas$(NC)"
	@echo ""
	@echo "$(YELLOW)Paso 3/4:$(NC) Compilando proyecto..."
	@./mvnw clean compile -q
	@echo "$(GREEN)  OK Proyecto compilado$(NC)"
	@echo ""
	@echo "$(YELLOW)Paso 4/4:$(NC) Instalando en repositorio Maven local..."
	@./mvnw install -DskipTests -q
	@echo "$(GREEN)  OK Proyecto instalado$(NC)"
	@echo ""
	@echo "$(GREEN)══════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)         SETUP COMPLETADO EXITOSAMENTE               $(NC)"
	@echo "$(GREEN)══════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(BLUE)Próximos pasos:$(NC)"
	@echo "  $(YELLOW)make db-up$(NC)   -> Levantar PostgreSQL"
	@echo "  $(YELLOW)make run$(NC)     -> Ejecutar aplicación"
	@echo ""

# ============================================================
# BASE DE DATOS (DOCKER)
# ============================================================

db-up:
	@echo "$(GREEN)Levantando PostgreSQL...$(NC)"
	@$(COMPOSE) up -d postgres
	@echo "$(GREEN)OK PostgreSQL corriendo en localhost:$(DB_PORT) (DB: $(DB_NAME))$(NC)"

db-down:
	@echo "$(YELLOW)Deteniendo servicios...$(NC)"
	@$(COMPOSE) down
	@echo "$(GREEN)OK Servicios detenidos$(NC)"

db-clean:
	@echo "$(RED)Eliminando contenedores y volúmenes...$(NC)"
	@$(COMPOSE) down -v
	@echo "$(GREEN)OK Limpieza completada$(NC)"

db-logs:
	@echo "$(BLUE)Logs en tiempo real (Ctrl+C para salir):$(NC)"
	@$(COMPOSE) logs -f postgres

restart:
	@echo "$(YELLOW)Reiniciando servicios...$(NC)"
	@$(COMPOSE) restart
	@echo "$(GREEN)OK Servicios reiniciados$(NC)"

db-connect:
	@echo "$(BLUE)Conectando a PostgreSQL...$(NC)"
	@$(COMPOSE) exec postgres psql -U $(DB_USER) -d $(DB_NAME)

db-reset:
	@echo "$(RED)Reseteando base de datos...$(NC)"
	@$(COMPOSE) down -v
	@$(COMPOSE) up -d postgres
	@echo "$(YELLOW)Esperando que PostgreSQL esté listo...$(NC)"
	@sleep 4
	@echo "$(GREEN)OK Base de datos reseteada — Flyway correrá las migraciones al iniciar$(NC)"

# ============================================================
# BUILD Y MAVEN
# ============================================================

compile:
	@echo "$(GREEN)Compilando proyecto...$(NC)"
	@./mvnw clean compile
	@echo "$(GREEN)OK Compilación exitosa$(NC)"

package:
	@echo "$(GREEN)Empaquetando proyecto...$(NC)"
	@./mvnw clean package -DskipTests
	@echo "$(GREEN)OK JAR generado en target/$(NC)"

install:
	@echo "$(GREEN)Instalando proyecto...$(NC)"
	@./mvnw clean install -DskipTests
	@echo "$(GREEN)OK Proyecto instalado$(NC)"

install-with-tests:
	@echo "$(GREEN)Instalando proyecto con tests...$(NC)"
	@./mvnw clean install
	@echo "$(GREEN)OK Proyecto instalado$(NC)"

# ============================================================
# TESTS
# ============================================================

test:
	@echo "$(GREEN)Ejecutando tests...$(NC)"
	@./mvnw test

test-unit:
	@echo "$(GREEN)Ejecutando tests unitarios...$(NC)"
	@./mvnw test -Dgroups="unit"

test-integration:
	@echo "$(GREEN)Ejecutando tests de integración...$(NC)"
	@./mvnw test -Dgroups="integration"

# ============================================================
# EJECUCIÓN
# ============================================================

run:
	@echo "$(GREEN)Iniciando Billwise API...$(NC)"
	@$(EXPORT_ENV) ./mvnw spring-boot:run

run-prod:
	@echo "$(GREEN)Iniciando Billwise API (producción)...$(NC)"
	@$(EXPORT_ENV) ./mvnw spring-boot:run -Dspring-boot.run.profiles=prod

start: db-up compile run

dev:
	@echo "$(BLUE)══════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)          INICIO RÁPIDO — BILLWISE API               $(NC)"
	@echo "$(BLUE)══════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(YELLOW)Paso 1/3:$(NC) Levantando infraestructura..."
	@$(MAKE) db-up
	@echo ""
	@echo "$(YELLOW)Paso 2/3:$(NC) Compilando cambios..."
	@./mvnw compile -q
	@echo "$(GREEN)  OK Compilación exitosa$(NC)"
	@echo ""
	@echo "$(YELLOW)Paso 3/3:$(NC) Iniciando aplicación..."
	@echo "$(GREEN)══════════════════════════════════════════════════════$(NC)"
	@$(EXPORT_ENV) ./mvnw spring-boot:run

# ============================================================
# LIMPIEZA
# ============================================================

clean:
	@echo "$(YELLOW)Limpiando archivos generados...$(NC)"
	@./mvnw clean
	@echo "$(GREEN)OK Limpieza completada$(NC)"

clean-all:
	@echo "$(RED)Limpieza profunda del proyecto...$(NC)"
	@./mvnw clean
	@rm -rf ~/.m2/repository/sys/azentic/billwise-api
	@rm -rf target/
	@echo "$(GREEN)OK Limpieza profunda completada$(NC)"

fresh-install: clean-all
	@echo "$(GREEN)Instalación desde cero...$(NC)"
	@./mvnw dependency:resolve dependency:resolve-plugins
	@./mvnw clean compile
	@./mvnw install -DskipTests
	@echo "$(GREEN)OK Instalación fresca completada$(NC)"

# ============================================================
# UTILIDADES
# ============================================================

status:
	@echo "$(BLUE)Estado de servicios:$(NC)"
	@echo ""
	@$(COMPOSE) ps

dependencies:
	@echo "$(BLUE)Árbol de dependencias:$(NC)"
	@./mvnw dependency:tree

gen-jwt:
	@echo "$(BLUE)JWT_SECRET generado:$(NC)"
	@openssl rand -base64 64 | tr -d '\n'
	@echo ""
	@echo "$(YELLOW)Copia el valor anterior en tu .env como JWT_SECRET=$(NC)"

ci: compile test package
	@echo "$(GREEN)OK Build de CI exitoso$(NC)"

# ============================================================
# GIT
# ============================================================

push:
	@if [ -z "$(m)" ]; then \
		echo "$(RED)Error: Proporciona un mensaje$(NC)"; \
		echo "$(YELLOW)Uso: make push m='tu mensaje'$(NC)"; \
		exit 1; \
	fi
	@git add .
	@git commit -m "$(m)"
	@git push origin $(BRANCH)
	@echo "$(GREEN)OK Push completado en origin/$(BRANCH)$(NC)"

pull:
	@git pull origin $(BRANCH)
	@echo "$(GREEN)OK Pull completado$(NC)"

git-status:
	@echo "$(BLUE)Estado Git (rama: $(BRANCH)):$(NC)"
	@git status

sync:
	@if [ -z "$(m)" ]; then \
		echo "$(RED)Error: Proporciona un mensaje$(NC)"; \
		echo "$(YELLOW)Uso: make sync m='tu mensaje'$(NC)"; \
		exit 1; \
	fi
	@git pull origin $(BRANCH)
	@git add .
	@git commit -m "$(m)"
	@git push origin $(BRANCH)
	@echo "$(GREEN)OK Sincronización completada$(NC)"
