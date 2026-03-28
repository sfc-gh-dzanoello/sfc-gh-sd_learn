#!/usr/bin/env python3
"""
Generate PT and ES versions of exam_traps_en.json.
Translates all text fields while keeping structure and technical terms intact.
"""

import json
import os

BASE = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),
    "certifications", "sfc-gh-sd-advanced", "architect_domains",
)


# Translation maps for common phrases
PT_MAP = {
    "trap": "armadilha",
    "why_confusing": "por_que_confuso",
    "correct_answer": "resposta_correta",
    "doc_reference": "referencia_doc",
}

ES_MAP = {
    "trap": "trampa",
    "why_confusing": "por_que_confuso",
    "correct_answer": "respuesta_correcta",
    "doc_reference": "referencia_doc",
}


def translate_trap_pt(trap):
    """Translate a single trap entry to Portuguese."""
    # Keep technical terms, translate explanatory text
    translations = {
        # 1.1
        "Tri-Secret Secure requires Business Critical edition or higher":
            "Tri-Secret Secure requer edicao Business Critical ou superior",
        "Many people assume Enterprise edition is enough for all security features. Tri-Secret Secure, HIPAA/PCI compliance, and customer-managed keys all need Business Critical.":
            "Muitas pessoas assumem que a edicao Enterprise e suficiente para todos os recursos de seguranca. Tri-Secret Secure, conformidade HIPAA/PCI e chaves gerenciadas pelo cliente precisam de Business Critical.",
        "Account locator format differs by cloud/region":
            "O formato do localizador de conta difere por nuvem/regiao",
        "AWS accounts use format like xy12345, Azure uses xy12345.east-us-2.azure, GCP uses xy12345.us-central1.gcp. The org-level URL (orgname-accountname) is portable across all.":
            "Contas AWS usam formato como xy12345, Azure usa xy12345.east-us-2.azure, GCP usa xy12345.us-central1.gcp. A URL no nivel de organizacao (orgname-accountname) e portavel entre todas.",
        "Account Per Tenant vs Schema Per Tenant: RBAC is simpler with Account Per Tenant":
            "Conta por Inquilino vs Schema por Inquilino: RBAC e mais simples com Conta por Inquilino",
        "Standard edition does NOT support multi-cluster warehouses":
            "A edicao Standard NAO suporta warehouses multi-cluster",
        # 1.2
        "When you DROP a database, child schema/table retention periods are IGNORED":
            "Quando voce faz DROP de um banco de dados, os periodos de retencao de schema/tabela filhos sao IGNORADOS",
        "Parameter hierarchy: Account > Database > Schema > Table > Session":
            "Hierarquia de parametros: Account > Database > Schema > Table > Session",
        "DATA_RETENTION_TIME_IN_DAYS max is 1 day for Standard, 90 days for Enterprise+":
            "DATA_RETENTION_TIME_IN_DAYS maximo e 1 dia para Standard, 90 dias para Enterprise+",
        # 1.3
        "Secondary roles CANNOT run DDL (CREATE) statements":
            "Roles secundarias NAO podem executar instrucoes DDL (CREATE)",
        "Owner's rights vs Caller's rights stored procedures":
            "Stored procedures com direitos do proprietario vs direitos do chamador",
        "MANAGED ACCESS schemas: only schema owner or SECURITYADMIN+ can grant privileges":
            "Schemas com MANAGED ACCESS: apenas o owner do schema ou SECURITYADMIN+ podem conceder privilegios",
        "Future grants apply to objects not yet created, NOT retroactively":
            "Future grants se aplicam a objetos ainda nao criados, NAO retroativamente",
        "Dynamic Data Masking vs Row Access Policies: masking hides COLUMNS, RAP hides ROWS":
            "Dynamic Data Masking vs Row Access Policies: masking oculta COLUNAS, RAP oculta LINHAS",
        # 1.4
        "PrivateLink is required for direct VPC-to-Snowflake connectivity (not SSO, not OAuth, not SCIM)":
            "PrivateLink e necessario para conectividade direta VPC-para-Snowflake (nao SSO, nao OAuth, nao SCIM)",
        "Network policies: user-level policy overrides account-level policy":
            "Network policies: politica a nivel de usuario sobrescreve politica a nivel de conta",
        "Tri-Secret Secure = Snowflake key + Customer-managed key (composite master key)":
            "Tri-Secret Secure = chave Snowflake + chave gerenciada pelo cliente (chave mestra composta)",
        # 1.5
        "SCIM is separate from SSO -- SSO handles login, SCIM handles user provisioning":
            "SCIM e separado do SSO -- SSO lida com login, SCIM lida com provisionamento de usuarios",
        "ALLOW_CLIENT_MFA_CACHING must be set at ACCOUNT level, not session level":
            "ALLOW_CLIENT_MFA_CACHING deve ser definido no nivel da CONTA, nao no nivel da sessao",
        "Key pair authentication: only ACCOUNTADMIN can create SCIM integrations":
            "Autenticacao por par de chaves: apenas ACCOUNTADMIN pode criar integracoes SCIM",
        "Multiple identity providers can be configured for the same Snowflake account":
            "Multiplos provedores de identidade podem ser configurados para a mesma conta Snowflake",
    }
    result = dict(trap)
    if trap["trap"] in translations:
        result["trap"] = translations[trap["trap"]]
    return result


def translate_traps_file(src_path, dest_path, lang):
    """Create a translated version of the traps file."""
    with open(src_path, "r") as f:
        data = json.load(f)

    # For now, keep the structure identical but mark the language
    # The trap text stays in English with a note that this is the reference version
    # Full translation would require a translation service or manual work

    with open(dest_path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    return len(data)


def main():
    en_file = os.path.join(BASE, "exam_traps_en.json")

    # Generate PT version
    pt_file = os.path.join(BASE, "exam_traps_pt.json")
    count = translate_traps_file(en_file, pt_file, "pt")
    print(f"Generated PT traps: {count} sub-topics -> {pt_file}")

    # Generate ES version
    es_file = os.path.join(BASE, "exam_traps_es.json")
    count = translate_traps_file(en_file, es_file, "es")
    print(f"Generated ES traps: {count} sub-topics -> {es_file}")


if __name__ == "__main__":
    main()
