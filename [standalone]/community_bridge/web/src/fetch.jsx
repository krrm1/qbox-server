export const fetchNui = async (cbName, data = {}) => {
    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    };

    try {
        const resourceName = window.GetParentResourceName?.() || '';
        const resp = await fetch(`https://${resourceName}/${cbName}`, options);
        
        if (!resp.ok) {
            throw new Error(`HTTP error! status: ${resp.status}`);
        }
        
        return await resp.json();
    } catch (error) {
        console.error(`Fetch error for ${cbName}:`, error);
        if (!window.GetParentResourceName?.()) {
            console.error('Resource name is null - are you testing in browser?');
        }
        return null;
    }
};