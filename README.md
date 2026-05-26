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
cd /vagrant
```

---
## Копируем ключ 
```bash
cp /vagrant/.vagrant/machines/server1/virtualbox/private_key ~/.ssh/server1_key
```
## Запуск playbook

```bash
ansible-playbook site.yml --ask-vault-pass
```

### Повторный запуск playbook

После первого bootstrap playbook пользователь `ops` уже создан и используется для дальнейшего управления сервером.

Перед повторным запуском необходимо изменить `inventory.ini`:

```ini
[servers]
server1 ansible_host=192.168.56.11

[servers:vars]
ansible_user=ops
ansible_ssh_private_key_file=/home/vagrant/.ssh/server1_key
```

После этого playbook можно запускать повторно:

```bash
ansible-playbook site.yml --ask-vault-pass
```

### Подключение по SSH под пользователем ops

После выполнения playbook подключение выполняется по SSH-ключу:

```bash
ssh -i ~/.ssh/server1_key ops@192.168.56.11
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

## Molecule (тестирование ролей)

Проект использует **Molecule** для тестирования Ansible-роли `ssh_hardening` в изолированной среде Docker.

Molecule позволяет автоматически проверить:
- корректность синтаксиса роли
- успешное применение конфигурации
- наличие обязательных файлов и настроек SSH
- идемпотентность роли
- базовую проверку безопасности

---

### Архитектура теста

Molecule запускает тестовый сценарий:

```
create → prepare → converge → verify → destroy
```

Где:

- **create** — поднимает Docker контейнер
- **prepare** — устанавливает openssh-server и runtime зависимости
- **converge** — применяет роль `ssh_hardening`
- **verify** — проверяет результат настройки
- **destroy** — удаляет тестовую среду

---

### Запуск Molecule

Перейти в директорию роли:

```bash
source ~/venv-molecule/bin/activate
```

Проверка, что molecule доступен:

```bash
molecule --version
```

Запуск полного теста:

```bash
molecule test
```

---

### Запуск отдельных стадий

```bash
molecule create
molecule converge
molecule verify
molecule destroy
```

---

### Что проверяется

#### SSH конфигурация

```bash
sshd -T
```

Проверяется:
- отключён root login
- отключена password authentication
- применены ограничения доступа

---

#### Наличие SSH конфигурации

```bash
ls -l /etc/ssh/sshd_config
```

---

#### Корректность SSH конфигурации

```bash
sshd -t
```

---

### Особенности запуска в Docker

Molecule использует контейнерную среду, поэтому:

- systemd отсутствует или ограничен
- некоторые runtime директории создаются в prepare stage
- сервис SSH не управляется через systemctl

---

### Почему Molecule используется

Molecule добавлен для:

- тестирования роли без Vagrant/VM
- проверки идемпотентности
- безопасной проверки изменений SSH конфигурации
- ускорения CI/CD пайплайна