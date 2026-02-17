# 2026-02-17T09:56:15.437484560
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis")

platform = client.create_platform_component(name = "kv260_platform",hw_design = "$COMPONENT_LOCATION/../../cpu_system_wrapper.xsa",os = "standalone",cpu = "psu_cortexa53_0",domain_name = "standalone_psu_cortexa53_0",architecture = "64-bit",compiler = "gcc")

comp = client.create_app_component(name="gpio_test",platform = "$COMPONENT_LOCATION/../kv260_platform/export/kv260_platform/kv260_platform.xpfm",domain = "standalone_psu_cortexa53_0")

platform = client.get_component(name="kv260_platform")
status = platform.build()

status = platform.build()

comp = client.get_component(name="gpio_test")
comp.build()

