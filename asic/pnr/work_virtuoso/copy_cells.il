let((sourceLibs targetLib srcLibObj targetLibObj cellList masterLayout newLayout)
    sourceLibs = list("CORELIB" "IOLIB_4M")
    targetLib = "zigbee_lib" ; Replace with your actual library name if different

    targetLibObj = ddGetObj(targetLib)
    if(targetLibObj then
        foreach(libName sourceLibs
            srcLibObj = ddGetObj(libName)
            if(srcLibObj then
                printf("Copying layouts from %s to %s\n" libName targetLib)
                foreach(cell srcLibObj~>cells
                    masterLayout = dbOpenCellViewByType(libName cell~>name "layout" "maskLayout" "r")
                    if(masterLayout then
                        printf("  Copying %s...\n" cell~>name)
                        newLayout = dbOpenCellViewByType(targetLib cell~>name "layout" "maskLayout" "a")
                        if(newLayout then
                            foreach(fig masterLayout~>shapes
                                errset(dbCopyFig(fig newLayout))
                            )
                            foreach(inst masterLayout~>instances
                                errset(dbCopyFig(inst newLayout))
                            )
                            foreach(via masterLayout~>vias
                                errset(dbCopyFig(via newLayout))
                            )
                            dbSave(newLayout)
                            dbClose(newLayout)
                        else
                            printf("    Failed to open target for %s\n" cell~>name)
                        )
                        dbClose(masterLayout)
                    )
                )
            else
                printf("Source library %s not found!\n" libName)
            )
        )
    else
        printf("Target library %s not found!\n" targetLib)
    )
)