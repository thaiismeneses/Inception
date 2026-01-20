NAME = Inception

COMPOSE = docker compose -f srcs/docker-compose.yml

#Cores
NC        = \033[0m
GREEN     = \033[1;32m
RED       = \033[1;31m
YELLOW    = \033[1;33m
BLUE      = \033[1;34m
CYAN      = \033[1;36m
MAGENTA   = \033[1;35m

all: build


banner:
	@echo "$(CYAN)"
	@echo "========================================"
	@echo "        🚀 Starting $(NAME)             "
	@echo "========================================"
	@echo "$(NC)"


build: banner
	@echo "$(GREEN) [CONSTRUINDO CONTAINERS...] $(NC)"
	$(COMPOSE) up --build -d
	@echo "$(GREEN) ✔ Containers Up!$(NC)"


up: banner
	@echo "$(GREEN) [SUBINDO CONTAINERS...] $(NC)"
	$(COMPOSE) up 
	@echo "$(GREEN) ✔ Containers Up!$(NC)"

down:
	@echo "$(YELLOW) [DERRUBANDO CONTAINERS...]$(NC)"
	$(COMPOSE) down
	@echo "$(YELLOW) ✔ Containers Down!$(NC)"


stop:
	@echo "$(RED) [PARANDO CONTAINERS...]$(NC)"
	$(COMPOSE) stop
	@echo "$(RED) ✔ Containers Stopped!$(NC)"


clean:
	@echo "$(MAGENTA) [REMOVENDO ORFÃOS...]$(NC)"
	$(COMPOSE) down --remove-orphans
	@echo "$(MAGENTA) ✔ Orfãos Removidos!$(NC)"


fclean:
	@echo "$(RED) [LIMPANDO TUDO...]$(NC)"
	$(COMPOSE) down --volumes --remove-orphans
	docker system prune -af
	@echo "$(RED) ✔ Limpeza Completa!$(NC)"



re: fclean build

logs:
	@echo "$(BLUE) [MOSTRANDO LOGS...]$(NC)"
	$(COMPOSE) logs -f

ps:
	@echo "$(CYAN) [STATUS DOS CONTAINERS...]$(NC)"
	$(COMPOSE) ps

prune:
	@echo "$(RED) [PRUNING DOCKER...]$(NC)"
	docker system prune -af
	@echo "$(RED) ✔ Docker Limpo!$(NC)"

.PHONY: all up down stop clean fclean re logs ps prune
