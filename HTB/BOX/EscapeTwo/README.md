# 🔥 EscapeTwo FULL AUTO ROOT | Automação Avançada em Red Team (Hack The Box) 🚩

**Domine a automação de ataques e escalada de privilégios na prática com este script profissional, didático e 100% automatizado!**

---

## 🎯 O que é o EscapeTwo FULL AUTO ROOT?

Este projeto oferece um script completo em Bash para automação total da máquina **EscapeTwo** do Hack The Box. Com foco didático, explicações claras e feedback visual constante, este script é ideal para aulas, demonstrações e treinamentos avançados em Red Team e segurança ofensiva.

---

## 🚀 Benefícios que você terá com este projeto:

- ✅ **Automação Total:** Realize enumeração, exploração e escalada de privilégios automaticamente.
- ✅ **Feedback Visual:** Entenda claramente cada passo através de mensagens intuitivas.
- ✅ **Didática Aprimorada:** Comentários explicativos detalhados para melhor aprendizado.

---

## 🔧 Recursos e Técnicas Utilizadas:

- ✔️ Enumeração de serviços (Nmap)
- ✔️ RID brute force com CrackMapExec
- ✔️ Extração de credenciais via arquivos SMB (smbclient)
- ✔️ Comandos remotos MSSQL (xp_cmdshell)
- ✔️ Exploração de Active Directory via BloodHound
- ✔️ Técnicas avançadas: Shadow Credentials (ESC4), ADCS exploitation (ESC1)
- ✔️ Extração de NT Hashes para acesso administrativo (Evil-WinRM)

---

## 🛠️ Como usar?

### Pré-requisitos
- Kali Linux atualizado
- Ferramentas pré-instaladas: Nmap, CrackMapExec, Impacket, Certipy-AD, BloodHound, Evil-WinRM, smbclient

### 📌 Instalação rápida:
```bash
git clone https://github.com/marcostolosa/CTF.git
cd CTF/HTB/BOX/EspaceTwo
chmod +x autoRoot.sh
```

### 🎬 Execução do script:
```bash
./autoRoot.sh -i <IP_ALVO>
```

### 🔄 Para limpar arquivos gerados:
```bash
./autoRoot.sh -R
```

---

## 📚 Explicação Detalhada das Etapas:

1. **Enumeração Inicial (Nmap)**
2. **Descoberta de usuários (RID brute)**
3. **Download automatizado de arquivos SMB**
4. **Ativação de comandos remotos MSSQL (xp_cmdshell)**
5. **Extração de credenciais do arquivo Excel**
6. **Enumeração completa do Active Directory (BloodHound)**
7. **Abuso de Shadow Credentials para escalada de privilégios**
8. **Modificação do template ADCS para emissão maliciosa de certificados**
9. **Extração e autenticação com NT Hash do Administrator**
10. **Shell Administrativo Completo (ROOT)**

---

## 🧑‍💻 Público-Alvo:

- Estudantes e profissionais de Ethical Hacking e Pentest
- Instrutores de cibersegurança e Red Team
- Entusiastas de segurança ofensiva interessados em automação
- Participantes de CTF (Capture The Flag)

---

## 🔥 Keywords (SEO)

`EscapeTwo`, `Hack The Box`, `Red Team`, `Automação de Pentest`, `Escalada de Privilégios`, `Shadow Credentials`, `Active Directory`, `BloodHound`, `Certipy`, `xp_cmdshell`, `Evil-WinRM`

---

## 🌟 Autor

**Marcos Tolosa (@ai.marcostolosa)**  
[Instagram](https://instagram.com/ai.marcostolosa) | [LinkedIn](https://www.linkedin.com/in/marcos-tolosa/) | [GitHub](https://github.com/marcostolosa)

Gostou? Não esqueça de ⭐ dar uma estrela ao projeto e compartilhar para ajudar mais pessoas a se tornarem profissionais em segurança ofensiva!

---

## ⚠️ Aviso Legal
Este projeto tem fins educacionais e éticos. O uso indevido é de responsabilidade exclusiva do usuário.

