# 🔍 dig.sh

`dig.sh` permet d'interroger les enregistrements DNS d'un nom de domaine et de son sous-domaine `www` depuis un terminal Linux.

**Enregistrements interrogés automatiquement :**

- `A`, `AAAA`, `Host`, `NS`, `MX`, `TXT`, `SRV`, `CAA` pour le domaine principal
- `A`, `AAAA`, `Host`, `TXT` pour `www.<domaine>`

**Commandes disponibles dans le menu :**

| Commande | Action |
|----------|--------|
| `whois`  | Lance un WHOIS sur le domaine |
| `ds`     | Interroge l'enregistrement DS (DNSSEC) |
| `exit`   | Quitte le script |
| *domaine* | Interroge directement un nouveau domaine |

---

## Prérequis

- Système : Terminal Linux
- Dépendances : `dig`, `host`, `whois`

Installation des dépendances si nécessaire :

```bash
# Debian / Ubuntu
sudo apt install dnsutils whois

# Arch Linux
sudo pacman -S bind whois
```

---

## Installation

### 1. Créer le fichier
```bash
nano dig.sh
```

Coller le contenu du script, puis sauvegarder : `Ctrl+O` → `Entrée` → `Ctrl+X`.

### 2. Rendre le script exécutable
```bash
chmod +x dig.sh
```

### 3. Vérifier
```bash
ls -l dig.sh
# doit afficher : -rwxr-xr-x ...
```

---

## Utilisation

### Lancement interactif
```bash
./dig.sh
```

Le script affiche l'animation de démarrage puis demande un nom de domaine :
```
  → Domaine : example.com
```

### Lancement direct avec un domaine en argument
```bash
./dig.sh example.com
```

Le script saute la saisie et affiche directement les résultats.

---

## Navigation

Une fois les résultats affichés, le menu propose :

```
╔══════════════════════════════════════════════╗
║         On continue de creuser ?             ║
║                                              ║
║       [whois]    [ds]    [exit]              ║
║                                              ║
╚══════════════════════════════════════════════╝
  → Nouveau domaine ou commande :
```

- Taper un nom de domaine relance une interrogation
- `whois` affiche les informations WHOIS du domaine courant
- `ds` affiche l'enregistrement DS (DNSSEC)
- `exit` quitte proprement le script

---

## Conseils

- Le script doit être lancé depuis le dossier où il se trouve (`./dig.sh`), ou placé dans un dossier présent dans votre `$PATH` pour être appelé depuis n'importe où :
```bash
sudo mv dig.sh /usr/local/bin/dig.sh
```

- Pour une utilisation fréquente, ajouter un alias dans `~/.bashrc` ou `~/.zshrc` :
```bash
alias dns='~/scripts/dig.sh'
```

---
