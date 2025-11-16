# Call of Duty Config Patcher

Script PowerShell pour optimiser les paramètres de Call of Duty Black Ops 7.

Je vous invite vivement à lire le script.
Il ne faut JAMAIS exécuter un script, surtout en mode administrateur, si on a un doute sur ce qui est réalisé par le script.
C'est une règle de bon sens mais tout le monde n'est pas expert. Donc si vous n'avez pas confiance dans le script, passez votre chemin.

Les étapes détails de mon opti BO7/Nvidia sont [ici](./docs/index.md).

## Fonctionnalités

- **Détection automatique** : Trouve automatiquement les fichiers de configuration (cod24, cod25, etc.)
- **Sauvegarde automatique** : Crée une archive ZIP horodatée avant toute modification
- **Modification intelligente** : Ne modifie que les valeurs différentes de celles déjà configurées
- **Préservation des commentaires** : Conserve tous les commentaires présents dans les fichiers
- **Sortie détaillée** : Affiche clairement les changements effectués

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
2. Placez-le dans le dossier recommandé : `C:/`

## Utilisation

### Méthode 1 : Exécution directe

p.s. normalement administrateur ne devrait pas être nécessaire, mais au cas où.

Ouvrez PowerShell en tant qu'administrateur (barre de recherche: Powershell, clic droit dessus, lancer en tant qu'administrateur) et exécutez :

```powershell
cd C:/
.\cod_config_patcher.ps1
```

Si vous avez un message d'erreur (en rouge) assez long, c'est que l'execution directe est bloquée (normal pour un Windows non optimisée), utilisez la méthode 2.

### Méthode 2 : Bypass de la politique d'exécution

Si vous rencontrez une erreur de politique d'exécution :

```powershell
PowerShell -ExecutionPolicy Bypass -File "C:/cod_config_patcher.ps1"
```

### Méthode 3 : Exécution depuis n'importe quel dossier

```powershell
& "C:/cod_config_patcher.ps1"
```

## Sortie du script

### Exemple de sortie réussie

```text
Scanning directory: C:\Users\USERNAME\Documents\Call of Duty\players

Found matching config pair: s.1.0.cod25
Will process the following files:
  - s.1.0.cod25.txt0
  - s.1.0.cod25.txt1

Creating backup archive: cod_backup_20251116_100745.zip
Backup created successfully

Modifying configuration files...

Processing file: s.1.0.cod25.txt0
  Changed ShowBlood : true -> false (comment preserved)
  Changed ShowBrass : true -> false (comment preserved)
  Skipped CorpseLimit : already set to 0
  Changed ShaderQuality : Medium -> Low (comment preserved)
  Result: 3 changes applied, 1 already correct

Processing file: s.1.0.cod25.txt1
  Changed NvidiaReflex : Disabled -> Enabled (comment preserved)
  Skipped BloodLimit : already set to true
  Result: 1 changes applied, 1 already correct

======================================
Operation completed successfully!
======================================
Total changes applied: 4
Backup location: C:\Users\USERNAME\Documents\Call of Duty\players\cod_backup_20251116_100745.zip

You can now launch Call of Duty with optimized settings.
```

## Emplacement des fichiers

### Fichiers de configuration

Les fichiers de configuration se trouvent dans :

```text
C:\Users\[USERNAME]\Documents\Call of Duty\players\
```

Le script recherche automatiquement les fichiers correspondant au pattern :

- `s.1.0.cod24.txt0` et `s.1.0.cod24.txt1`
- `s.1.0.cod25.txt0` et `s.1.0.cod25.txt1`
- Ou tout autre fichier `s.1.0.cod*.txt0` avec son `.txt1` correspondant

### Sauvegardes

Les sauvegardes sont créées au même emplacement que les fichiers de configuration avec le format :

```text
cod_backup_YYYYMMDD_HHMMSS.zip
```

Exemple : `cod_backup_20251116_100745.zip`

## Restauration

Pour restaurer une configuration précédente :

1. Localisez le fichier ZIP de sauvegarde dans le dossier `players`
2. Extrayez les fichiers `.txt0` et `.txt1`
3. Remplacez les fichiers actuels par ceux de la sauvegarde

```powershell
# Exemple de restauration manuelle
$backupPath = "C:\Users\USERNAME\Documents\Call of Duty\players\cod_backup_20251116_100745.zip"
$destPath = "C:\Users\USERNAME\Documents\Call of Duty\players\"

Expand-Archive -Path $backupPath -DestinationPath $destPath -Force
```

## Dépannage

### Erreur : "Directory not found"

Le dossier Call of Duty n'existe pas. Vérifiez que :

- Call of Duty est installé
- Vous avez lancé le jeu au moins une fois
- Le chemin correspond à votre installation

### Erreur : "No config files found"

Aucun fichier de configuration trouvé. Solutions :

- Lancez Call of Duty une fois pour créer les fichiers
- Vérifiez manuellement le contenu du dossier `players`
- Assurez-vous que les fichiers ne sont pas cachés

### Erreur : "No matching .txt0 and .txt1 file pair found"

Un fichier `.txt0` existe mais pas son `.txt1` correspondant (ou inversement). Solutions :

- Vérifiez l'intégrité des fichiers du jeu
- Lancez le jeu pour régénérer les fichiers manquants

### Erreur : "Execution Policy"

PowerShell bloque l'exécution du script. Solution :

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Ou utilisez la Méthode 2 avec le paramètre `-ExecutionPolicy Bypass`.

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

- Call of Duty: Black Ops 7

### Systèmes supportés

- Windows 10 (version 1809 ou supérieure)
- Windows 11

## Changelog

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

Script créé pour optimiser les performances de Call of Duty sur PC.
