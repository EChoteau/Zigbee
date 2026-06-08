let((sourceLibs targetLib srcLibObj targetLibObj srcCellObj targetCellObj)
    sourceLibs = list("CORELIB" "IOLIB_4M" "TECH_C35B4")
    targetLib = "zigbee_lib" ; Assure-toi que c'est bien le nom de ta lib

    targetLibObj = ddGetObj(targetLib)
    
    if(targetLibObj then
        foreach(libName sourceLibs
            srcLibObj = ddGetObj(libName)
            if(srcLibObj then
                printf("Copying ALL views from %s to %s\n" libName targetLib)
                
                foreach(cell srcLibObj~>cells
                    srcCellObj = ddGetObj(libName cell~>name)
                    
                    ; On vérifie que la cellule n'existe pas déjà dans la lib cible pour éviter les erreurs
                    targetCellObj = ddGetObj(targetLib cell~>name)
                    
                    if(targetCellObj then
                        printf("  Skipping %s (Already exists in %s)\n" cell~>name targetLib)
                    else
                        printf("  Copying entire cell %s...\n" cell~>name)
                        ; La fonction magique qui copie toute l'arborescence de la cellule
                        ccpCopy(srcCellObj targetLibObj "" 'ccpCopyDesign)
                    )
                )
            else
                printf("Source library %s not found!\n" libName)
            )
        )
    else
        printf("Target library %s not found!\n" targetLib)
    )
    printf("--- Copy finished! ---\n")
)