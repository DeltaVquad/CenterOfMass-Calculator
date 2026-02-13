import adsk.core
import adsk.fusion
import traceback
import csv
import os

def run(context):
    ui = None
    try:
        app = adsk.core.Application.get()
        ui = app.userInterface
        
        if ui.activeSelections.count == 0:
            ui.messageBox('Atenção: Nada selecionado.\n\nSelecione Componentes ou Corpos antes de executar.')
            return

        script_dir = os.path.dirname(os.path.realpath(__file__))
        project_root = os.path.dirname(script_dir)
        
        csv_path = os.path.join(project_root, 'componentes_posicao.csv')

        try:
            with open(csv_path, 'a'): pass
        except PermissionError:
            ui.messageBox(f'Erro: O arquivo "{csv_path}" está aberto.\nFeche o Excel e tente novamente.')
            return
        except:
            pass

        with open(csv_path, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['nome', 'x_mm', 'y_mm', 'z_mm', 'vol_mm3', 'Tipo'])
            count = 0
            
            for i in range(ui.activeSelections.count):
                sel = ui.activeSelections.item(i)
                ent = sel.entity 

                valid_entity = False
                com_global = None
                volume_cm3 = 0.0
                name = ""
                ent_type = ""

                if isinstance(ent, adsk.fusion.Occurrence):
                    valid_entity = True
                    name = ent.name
                    ent_type = "Componente"
                    phys = ent.getPhysicalProperties(adsk.fusion.CalculationAccuracy.HighCalculationAccuracy)
                    com_global = phys.centerOfMass
                    volume_cm3 = phys.volume

                elif isinstance(ent, adsk.fusion.BRepBody):
                    valid_entity = True
                    name = ent.name
                    ent_type = "Corpo"
                    phys = ent.getPhysicalProperties(adsk.fusion.CalculationAccuracy.HighCalculationAccuracy)
                    com_local = phys.centerOfMass
                    volume_cm3 = phys.volume
                    
                    com_global = com_local.copy()
                    if ent.assemblyContext:
                        com_global.transformBy(ent.assemblyContext.transform)

                if valid_entity and com_global:
                    x_out = com_global.x * 10.0
                    y_out = com_global.y * 10.0
                    z_out = com_global.z * 10.0
                    vol_mm3 = volume_cm3 * 1000.0

                    writer.writerow([
                        name,
                        f"{x_out:.3f}",
                        f"{y_out:.3f}",
                        f"{z_out:.3f}",
                        f"{vol_mm3:.3f}",
                        ent_type
                    ])
                    count += 1
        
        if count > 0:
            ui.messageBox(f'Sucesso!\n{count} itens exportados.\nSalvo em: {csv_path}')
        else:
            ui.messageBox('Nada exportado. Selecione Componentes ou Corpos.')

    except:
        if ui:
            ui.messageBox('Erro:\n{}'.format(traceback.format_exc()))