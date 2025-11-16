# Call of Duty Config Patcher

Je vous invite vivement à lire le script.
Il ne faut JAMAIS exécuter un script, surtout en mode administrateur, si on a un doute sur ce qui est réalisé par le script.
C'est une règle de bon sens mais tout le monde n'est pas expert. Donc si vous n'avez pas confiance dans le script, passez votre chemin.

Les étapes détails de mon opti BO7/Nvidia sont [ici](./docs/index.md).
Script PowerShell pour optimiser automatiquement les paramètres de Call of Duty (Black Ops Cold War, Modern Warfare, Warzone).

## Fonctionnalités

- **Détection automatique** : Trouve automatiquement les fichiers de configuration (cod24, cod25, bt.cod25, etc.)
- **Multi-formats** : Supporte tous les formats de fichiers de configuration Call of Duty
- **Multi-emplacements** : Recherche dans les deux emplacements possibles de configuration
- **Sauvegarde automatique** : Crée une archive ZIP horodatée avant toute modification
- **Modification intelligente** : Ne modifie que les valeurs différentes de celles déjà configurées
- **Préservation des commentaires** : Conserve tous les commentaires présents dans les fichiers
- **Sortie détaillée** : Affiche clairement les changements effectués pour chaque fichier

## Formats de fichiers supportés

Le script détecte automatiquement tous les formats de configuration :

| Format                | Exemple               | Version du jeu        |
| --------------------- | --------------------- | --------------------- |
| `s.1.0.cod24.txt*`    | `s.1.0.cod24.txt0`    | Black Ops Cold War    |
| `s.1.0.cod25.txt*`    | `s.1.0.cod25.txt0`    | Modern Warfare II/III |
| `s.1.0.bt.cod25.txt*` | `s.1.0.bt.cod25.txt0` | Warzone, Black Ops 6  |

Le script recherche les paires de fichiers `.txt0` et `.txt1` correspondantes.

## Paramètres optimisés

Le script configure automatiquement 12 paramètres pour améliorer les performances :

| Paramètre           | Valeur   | Description                             |
| ------------------- | -------- | --------------------------------------- |
| NvidiaReflex        | Enabled  | Active la réduction de latence NVIDIA   |
| BloodLimit          | true     | Limite les effets de sang               |
| BloodLimitInterval  | 2000     | Intervalle entre effets de sang (ms)    |
| ShowBlood           | false    | Désactive l'affichage du sang           |
| ShowBrass           | false    | Désactive l'éjection de douilles        |
| DepthOfFieldQuality | Low      | Réduit la qualité du flou de profondeur |
| CorpseLimit         | 0        | Désactive les cadavres persistants      |
| ShaderQuality       | Low      | Réduit la qualité des shaders           |
| SubdivisionLevel    | 0        | Désactive la subdivision de surface     |
| BulletImpacts       | false    | Désactive les impacts de balles         |
| TerrainQuality      | Very Low | Qualité minimale du terrain             |
| Tessellation        | 0_Off    | Désactive la tessellation               |

## Installation

### Prérequis

- Windows 10 ou Windows 11
- PowerShell 5.0 ou supérieur (inclus par défaut)
- Call of Duty installé avec des fichiers de configuration existants

### Téléchargement

1. Téléchargez le fichier `cod_config_patcher.ps1`
2. Placez-le dans le dossier recommandé : `C:\`

## Utilisation

:warning: Pensez à refaire vos shaders après avoir appliqué les nouveaux settings. :warning:

### Méthode 1 : Exécution directe

p.s. normalement administrateur ne devrait pas être nécessaire, mais au cas où.

Ouvrez PowerShell en tant qu'administrateur (barre de recherche: Powershell, clic droit dessus, lancer en tant qu'administrateur) et exécutez :

```powershell
cd C:\
.\cod_config_patcher.ps1
```

Si vous avez un message d'erreur (en rouge) assez long, c'est que l'execution directe est bloquée (normal pour un Windows non optimisée), utilisez la méthode 2.

### Méthode 2 : Bypass de la politique d'exécution

Si vous rencontrez une erreur de politique d'exécution :

```powershell
PowerShell -ExecutionPolicy Bypass -File "C:\cod_config_patcher.ps1"
```

### Méthode 3 : Exécution depuis n'importe quel dossier

```powershell
& "C:\cod_config_patcher.ps1"
```

## Sortie du script

### Exemple de sortie réussie

```text
Call of Duty Config Patcher v2.2
=================================

Searching for Call of Duty config files...

Scanning: C:\Users\USERNAME\Documents\Call of Duty\players
  Found pair: s.1.0.cod24

Scanning: C:\Users\USERNAME\AppData\Local\Activision\Call of Duty\Players
  Found pair: s.1.0.bt.cod25

Found 2 config pair(s) to process

======================================
Processing: s.1.0.cod24
Location: C:\Users\USERNAME\Documents\Call of Duty\players
======================================

Creating backup: cod_backup_s.1.0.cod24_20251116_181245.zip
Backup created successfully

Modifying configuration files...
  Processing: s.1.0.cod24.txt0
    Changed ShowBlood : true -> false (comment preserved)
    Changed ShowBrass : true -> false
    Skipped CorpseLimit : already set to 0
    Result: 2 changes, 1 unchanged

  Processing: s.1.0.cod24.txt1
    Changed NvidiaReflex : Disabled -> Enabled (comment preserved)
    Result: 1 changes, 0 unchanged

Completed: s.1.0.cod24 (3 total changes)

======================================
Processing: s.1.0.bt.cod25
Location: C:\Users\USERNAME\AppData\Local\Activision\Call of Duty\Players
======================================

Creating backup: cod_backup_s.1.0.bt.cod25_20251116_181246.zip
Backup created successfully

Modifying configuration files...
  Processing: s.1.0.bt.cod25.txt0
    Changed ShaderQuality : Medium -> Low (comment preserved)
    Result: 1 changes, 0 unchanged

  Processing: s.1.0.bt.cod25.txt1
    Skipped NvidiaReflex : already set to Enabled
    Result: 0 changes, 1 unchanged

Completed: s.1.0.bt.cod25 (1 total changes)

======================================
All Operations Completed!
======================================
Processed config pairs: 2
Total changes applied: 4

Backups created in their respective directories.
You can now launch Call of Duty with optimized settings.
```

## Emplacement des fichiers

Le script recherche automatiquement les fichiers de configuration dans :

### Emplacement 1 : Documents (ancien)

```text
%USERPROFILE%\Documents\Call of Duty\players\
```

Exemple : `C:\Users\USERNAME\Documents\Call of Duty\players\`

### Emplacement 2 : LocalAppData (nouveau/recommandé)

```text
%LOCALAPPDATA%\Activision\Call of Duty\Players\
```

Exemple : `C:\Users\USERNAME\AppData\Local\Activision\Call of Duty\Players\`

Le script traite **tous les fichiers trouvés** dans les deux emplacements.

### Sauvegardes


Les sauvegardes sont créées dans le **même dossier** que les fichiers de configuration originaux avec le format :

```text
cod_backup_[NOM_BASE]_YYYYMMDD_HHMMSS.zip
```

Exemples :

- `cod_backup_s.1.0.cod24_20251116_181245.zip`
- `cod_backup_s.1.0.cod25_20251116_181246.zip`
- `cod_backup_s.1.0.bt.cod25_20251116_181247.zip`

Chaque paire de fichiers a sa propre sauvegarde indépendante.

## Restauration

Pour restaurer une configuration précédente :

1. Localisez le fichier ZIP de sauvegarde dans le dossier approprié
2. Extrayez les fichiers `.txt0` et `.txt1`
3. Remplacez les fichiers actuels

## Dépannage

### Erreur : "No config files found in any location"

Aucun fichier de configuration trouvé dans les deux emplacements. Solutions :

- Lancez Call of Duty au moins une fois pour générer les fichiers
- Vérifiez manuellement les deux dossiers
- Assurez-vous que les fichiers ne sont pas cachés

### Erreur : "No matching .txt0 and .txt1 file pair found"

Un fichier `.txt0` existe mais pas son `.txt1` correspondant (ou inversement). Solutions :

- Vérifiez l'intégrité des fichiers du jeu via Battle.net ou Steam
- Lancez le jeu pour régénérer les fichiers manquants
- Supprimez les fichiers orphelins et relancez le jeu

### Erreur : "Execution Policy"

PowerShell bloque l'exécution du script. Solutions :

```powershell
# Solution permanente (recommandée)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Solution temporaire
PowerShell -ExecutionPolicy Bypass -File "C:/cod_config_patcher.ps1"
```

### Le script ne trouve qu'un seul emplacement

C'est normal ! Call of Duty peut stocker ses configurations dans l'un ou l'autre emplacement selon :

- La version du jeu
- Le launcher utilisé (Battle.net, Steam)
- Les mises à jour récentes

Le script traite automatiquement tous les fichiers trouvés.

## Personnalisation

Pour modifier les valeurs appliquées, éditez la section `$configChanges` du script :

```powershell
$configChanges = @{
    "NvidiaReflex" = "Enabled"
    "ShowBlood" = "false"
    # Ajoutez ou modifiez les paramètres ici
}
```

## Sécurité

- Le script ne modifie **que** les fichiers de configuration Call of Duty
- Une sauvegarde est **toujours** créée avant toute modification
- Le script ne nécessite **pas** de privilèges administrateur
- Le code source est entièrement lisible et auditable

# Benchmarks in-game

Les settings ont été testé sur un PC qui n'est pas trop récent et un gain notable de FPS et une baisse de l'input lag a été constaté.

Avant settings : env 205 FPS avec 14 ms d'input lag (AMD FLM)
Après patch : 238 FPS avec 9-10 ms d'input lag.

[Lire les détails](./docs/index.md)

## Support

### Jeux compatibles

- Call of Duty: Black Ops Cold War (cod24)
- Call of Duty: Modern Warfare (2019)
- Call of Duty: Warzone (bt.cod25)
- Call of Duty: Modern Warfare II (cod25)
- Call of Duty: Modern Warfare III (cod25)
- Call of Duty: Black Ops 6 et 7 (bt.cod25)
- Toute version future utilisant les formats cod* ou bt.cod*

### Systèmes supportés

- Windows 10 (version 1809 ou supérieure)
- Windows 11

## FAQ

### Quelle est la différence entre cod24, cod25 et bt.cod25 ?

- **cod24** : Utilisé par Black Ops Cold War et anciennes versions
- **cod25** : Utilisé par Modern Warfare II/III
- **bt.cod25** : Utilisé par Warzone et Black Ops 6 (Battle.net version)

Le script détecte et traite automatiquement tous ces formats.

### Pourquoi deux emplacements différents ?

Activision a changé l'emplacement des fichiers de configuration avec les mises à jour récentes. Les anciennes versions utilisent `Documents`, les nouvelles versions utilisent `LocalAppData`.

### Le script va-t-il casser mes paramètres ?

Non. Le script crée toujours une sauvegarde avant toute modification. Vous pouvez restaurer vos paramètres à tout moment.

### Puis-je exécuter le script plusieurs fois ?

Oui. Le script ne modifie que les valeurs différentes. S'il détecte que les paramètres sont déjà corrects, il les ignore.

### Les modifications persistent-elles après une mise à jour du jeu ?

Généralement oui, mais certaines mises à jour majeures peuvent réinitialiser les configurations. Réexécutez simplement le script après une mise à jour.

### Le script fonctionne-t-il avec Black Ops 6 ?

Oui ! Black Ops 6 utilise le format `s.1.0.bt.cod25` qui est maintenant supporté par le script.

## Changelog

### Version 2.2 (2025-11-16)

- Ajout du support pour le format `s.1.0.bt.cod25` (Warzone, Black Ops 6)
- Recherche multi-patterns améliorée
- Prévention des doublons de fichiers
- Messages d'erreur plus informatifs avec liste des patterns supportés

### Version 2.1 (2025-11-16)

- Ajout du support multi-emplacements (Documents + LocalAppData)
- Traitement de toutes les paires de fichiers trouvées
- Sauvegardes séparées pour chaque paire
- Interface améliorée avec résumé détaillé
- Meilleure gestion des erreurs

### Version 2.0 (2025-11-16)

- Détection automatique des fichiers cod24/cod25
- Recherche intelligente des paires .txt0/.txt1
- Messages d'erreur améliorés
- Interface utilisateur plus claire

### Version 1.1 (2025-11-15)

- Ajout de la détection des valeurs identiques
- Préservation des commentaires inline
- Compteur de changements précis

### Version 1.0 (2025-11-15)

- Version initiale
- Sauvegarde automatique
- Modification de 12 paramètres

## Licence

Ce script est fourni "tel quel" sans garantie. Utilisez-le à vos propres risques.

## Auteur

vignemail1
