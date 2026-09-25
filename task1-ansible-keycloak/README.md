# Task 1 — Ansible: создание пользователей в Keycloak

Ansible-плейбук для создания пользователей в Keycloak.

Плейбук поддерживает два режима:

* создание одного пользователя через `--extra-vars`;
* создание нескольких пользователей из YAML-файла.

## Структура

```text
task1-ansible-keycloak/
├── group_vars/
│   └── all/
│       ├── vars.yml
│       └── vault.yml
├── inventory.ini
├── keycloak_users.yml
├── users.yml
├── .gitignore
└── README.md
```


## Что делает плейбук

Для каждого пользователя плейбук:

* создаёт пользователя в указанном realm Keycloak;
* заполняет `username`, `email`, `firstName`, `lastName`;
* добавляет пользователя в указанные группы;
* устанавливает временный пароль и требует сменить пароль при первом входе;
* проверяет существование групп до создания пользователей;

## Переменные окружения

Основные параметры Keycloak задаются через переменные.

`group_vars/all/vars.yml`:

```yaml
keycloak_url: "your_keycloak_url"
keycloak_realm: "your_keycloak_realm"
keycloak_admin_realm: "your_keycloak_admin_realm:"
keycloak_admin_username: "your_keycloak_admin_username"
```

Секретные значения хранятся в `group_vars/all/vault.yml`, зашифрованном с помощью Ansible Vault.
- `keycloak_admin_password` — пароль администратора Keycloak;
- `keycloak_temporary_password` — временный пароль, устанавливаемый новым пользователям.

## Режим 1 — один пользователь

Данные пользователя передаются через `--extra-vars`.

Пример:

```bash
ansible-playbook -i inventory.ini keycloak_users.yml \
  --ask-vault-pass \
  -e '{"email":"olga.novikova@example.com","fio":"Olga Novikova","user_groups":["developers","analysts"]}'
```

Параметры:

* `email` — email и username пользователя;
* `fio` — ФИО;
* `user_groups` — список групп Keycloak.

## Режим 2 — несколько пользователей

Пользователи передаются через `users.yml`.

Пример структуры файла: users.yml

Запуск:

```bash
ansible-playbook -i inventory.ini keycloak_users.yml \
  --ask-vault-pass \
  -e "users_file=users.yml"
```


## Требования

Для запуска необходимы:

* Ansible;
* доступный Keycloak;
* настроенный realm;
* существующие группы, указанные в данных пользователей;
* Ansible Vault.
