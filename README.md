# DevOps Test Task

## Описание

Данный проект автоматизирует настройку и базовое hardening Linux-сервера с использованием Ansible.

Проект выполняется в Vagrant-окружении (Vagrant используется для поднятия тестовой инфраструктуры).

### Что делает playbook:
- базовая настройка системы (packages, utilities)
- создание пользователя `ops`
- SSH hardening (отключение root и password auth)
- настройка firewall (UFW)
- установка security tools (fail2ban, auditd)
- деплой Node Exporter (наблюдаемость)
- управление секретами через Ansible Vault
- health-check инфраструктуры

---

## Архитектура

### Схема инфраструктуры

| Host    | Роль                  |
|---------|----------------------|
| manager | Ansible control node |
| server1 | Managed node         |

---

## Быстрый старт

### 1. Поднять инфраструктуру

```bash
vagrant up
```

---

### 2. Подключиться к control node

```bash
vagrant ssh manager
```

---

### 3. Перейти в проект

```bash
cd ~/vagrant
```

---

## Запуск playbook

```bash
ansible-playbook site.yml --ask-vault-pass
```

---

## Как передать vault password

При выполнении команды Ansible запросит пароль:

```
Vault password:
```

Пример для тестового задания:

```
vault123
```

---

## Проверка результата

### 1. SSH hardening

```bash
sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin|allowusers'
```

Ожидаемо:

```
permitrootlogin no
passwordauthentication no
allowusers ops
```

---

### 2. Проверка SSH сервиса

```bash
systemctl status ssh
```

---

### 3. Проверка firewall (UFW)

```bash
sudo ufw status verbose
```

Ожидаемо:
- default: deny incoming
- allow OpenSSH

---

### 4. Проверка Node Exporter

```bash
curl http://localhost:9100/metrics
```

Ожидаемо:
- вывод Prometheus metrics

---

### 5. Проверка секретов

```bash
sudo ls -l /etc/example-app/config.env
```

Ожидаемо:

```
-rw------- root root
```

---

## Idempotency

Playbook является идемпотентным:

```bash
ansible-playbook site.yml --ask-vault-pass
```

Повторный запуск не должен изменять систему без необходимости.

---

## Безопасность

- root login отключён
- password authentication отключён
- секреты хранятся через Ansible Vault
- Node Exporter доступен только на localhost
- firewall ограничивает входящие подключения

---

## Структура ролей

- common — базовые пакеты
- users — пользователь ops
- ssh_hardening — SSH настройки
- firewall — UFW правила
- observability — Node Exporter
- secrets — vault секреты
- healthcheck — проверки инфраструктуры

---

## Ключевая идея

Проект демонстрирует production-style подход:

- модульная архитектура Ansible
- безопасность по умолчанию
- идемпотентность
- observability
- инфраструктурные проверки