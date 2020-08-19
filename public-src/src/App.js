import React, { useState, useEffect, useCallback } from 'react';
import Axios from 'axios';
import Menu, { Item, SubMenu } from './MenuApi';
import './App.css';

function App() {
    const [id, setId] = useState(0);
    const [name, setName] = useState("Invalid");
    const [playerNearby, setPlayerNearby] = useState(false);
    const [k9Data, setK9Data] = useState({});

    const handleMessage = useCallback(event => {
        if (!event.data) return
        const data = event.data
        switch (data.type) {
            case 'closestPlayer':
                if (data.id === undefined || data.name === undefined) {
                    setPlayerNearby(false)
                } else {
                    setId(data.id)
                    setName(data.name)
                    setPlayerNearby(true)
                }
                break
            case 'k9Data':
                if (data.data) {
                    setK9Data(data.data)
                }
                break
            default:
        }
    }, [])

    useEffect(() => {
        window.addEventListener('message', handleMessage)
        return () => {
            window.removeEventListener('message', handleMessage)
        }
    }, [handleMessage])

    function toggleHandsUp() {
        Axios.post('http://jcrp-toolbox/executeCommand', JSON.stringify('e handsup'))
    }
    function toggleCuff() {
        if (!playerNearby) return Axios.post('http://jcrp-toolbox/displayMsg', JSON.stringify('No player nearby.'))
        Axios.post('http://jcrp-toolbox/executeCommand', JSON.stringify('cuff ' + id))
    }
    function toggleDrag() {
        if (!playerNearby) return Axios.post('http://jcrp-toolbox/displayMsg', JSON.stringify('No player nearby.'))
        Axios.post('http://jcrp-toolbox/executeCommand', JSON.stringify('drag ' + id))
    }
    function setSpikes(double) {
        Axios.post('http://jcrp-toolbox/setSpikes', JSON.stringify(double))
    }
    function removeSpikes() {
        Axios.post('http://jcrp-toolbox/removeSpikes', JSON.stringify())
    }
    function spawnObject(obj) {
        Axios.post('http://jcrp-toolbox/spawnObject', JSON.stringify(obj))
    }
    function deleteCloseObjects() {
        Axios.post('http://jcrp-toolbox/deleteCloseObjects', JSON.stringify())
    }
    function nuiCallback(type, data) {
        Axios.post('http://jcrp-toolbox/' + type, JSON.stringify(data))
    }


    return (
        <Menu title="JCRP Toolbox">
            <SubMenu label="Actions" title={playerNearby ? `[${id}] ${name}` : 'No player nearby.'}>
                <Item label="Cuff / Uncuff" onSelect={toggleCuff} />
                <Item label="Drag" onSelect={toggleDrag} />
            </SubMenu>
            {k9Data.summoned ?
                <SubMenu label="K9">
                    <Item label={`Follow${k9Data.following ? 'ing' : ''}`} onSelect={() => nuiCallback('k9follow')} />
                    <Item label="Sit" onSelect={() => nuiCallback('sit')} />
                    <Item label="Laydown" onSelect={() => nuiCallback('laydown')} />
                    <Item label="Enter/Exit vehicle" onSelect={() => nuiCallback('vehicletoggle')} />
                    <Item label="Unsummon K9" onSelect={() => nuiCallback('toggleK9')} />
                </SubMenu>
                :
                <SubMenu label="K9">
                    <Item label="Summon K9" onSelect={() => nuiCallback('toggleK9')} />
                </SubMenu>
            }
            <SubMenu label="Spikes">
                <Item label="Place Spikes" onSelect={() => setSpikes(false)} />
                <Item label="Place 2x Spikes" onSelect={() => setSpikes(true)} />
                <Item label="Remove Spikes" onSelect={removeSpikes} />
            </SubMenu>
            <SubMenu label="Objects" title="Object Spawner">
                <Item label="Police Barrier" onSelect={() => spawnObject('policeBarrier')} />
                <Item label="Road Barrier" onSelect={() => spawnObject('roadBarrier')} />
                <Item label="Road Barrier Arrow" onSelect={() => spawnObject('roadBarrierArrow')} />
                <Item label="Traffic Cone" onSelect={() => spawnObject('cone')} />
                <Item label="Traffic Barrel" onSelect={() => spawnObject('trafficBarrel')} />
                <Item label="Remove Close Objects" onSelect={deleteCloseObjects} />
            </SubMenu>
            <Item label="Hands up" onSelect={toggleHandsUp} />
        </Menu>
        /*
        display &&
        <div className='Container'>
            <div className='title'>{`[${id}] ${name}`}</div>
            <ul>
                {listItems.map((item, index) => (
                <li key={index} className={index === listIndex ? 'selected' : ''}>{item.label}</li>
                ))}
            </ul>
        </div>
        */
    );
}

export default App;
