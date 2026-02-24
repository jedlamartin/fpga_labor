# 2026-02-24T09:48:00.471334237
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.get_component(name="kv260_platform")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../cpu_system_wrapper.xsa")

status = platform.build()

comp = client.create_app_component(name="dma_test",platform = "$COMPONENT_LOCATION/../kv260_platform/export/kv260_platform/kv260_platform.xpfm",domain = "standalone_psu_cortexa53_0")

status = platform.build()

comp = client.get_component(name="gpio_test")
comp.build()

status = platform.build()

comp = client.get_component(name="dma_test")
comp.build()

status = comp.clean()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

component = client.get_component(name="dma_test")

lscript = component.get_ld_script(path="/mnt/work/fpga_labor/fpga_labor/vitis/dma_test/src/lscript.ld")

lscript.regenerate()

status = platform.build()

comp.build()

comp.set_app_config(key = "USER_LINKER_SCRIPT", values = ["/mnt/work/fpga_labor/fpga_labor/vitis/dma_test/src/lscript.ld"])

comp.set_app_config(key = "USER_LINKER_SCRIPT", values = ["/mnt/work/fpga_labor/fpga_labor/vitis/dma_test/src/lscript.ld"])

comp.set_app_config(key = "USER_LINKER_SCRIPT", values = ["/mnt/work/fpga_labor/fpga_labor/vitis/dma_test/src/lscript.ld"])

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

